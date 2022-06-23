#!/usr/bin/env python3

# print the cumulated cpu + memory usage of a process tree

# loosely based on https://gist.github.com/meganehouser/1752014
# license: MIT

# pip install psutil prefixed
# nix-shell -p python3 python3.pkgs.{psutil,prefixed}

import psutil
from prefixed import Float

import time
import sys
import shlex

config_interval = 1
config_root_process_name = 'nix-daemon'

psutil.cpu_percent() # start monitoring cpu

cpu_count = psutil.cpu_count()
cpu_width = len(str(cpu_count * 100))
if cpu_width < len('load'):
  cpu_width = len('load')

# https://psutil.readthedocs.io/en/latest/#recipes
def find_procs_by_name(name):
  "Return a list of processes matching 'name'."
  ls = []
  for p in psutil.process_iter(['name']):
    if p.info['name'] == name:
      ls.append(p)
  return ls

def find_root_process(name):
  ls = find_procs_by_name(name)
  if len(ls) == 0:
    raise Exception("find_root_process: not found root proc")
  if len(ls) != 1:
    print(f"find_root_process: found multiple root procs:")
    for p in ls:
      print(f"  {p}")
    print(f"find_root_process: root_process = {ls[0]}")
  #assert len(ls) == 1 # !=1 when build is running
  return ls[0]

last_cpu_time = dict()

def get_process_tree_slow(process, depth=0):
  """
  build process tree in depth-first traversal to cumulate:
  cpu -> sum_cpu
  mem -> sum_mem

  naive version. takes 20 seconds per loop on a busy server = 80% cpu usage
  """
  indent = "  "
  sum_cpu = 0
  sum_mem = 0
  sum_rss = 0
  children = []
  try:
    with process.oneshot():
      cpu_times = process.cpu_times()
      memory_info = process.memory_info()
      rss = memory_info.rss
      #cpu = process.cpu_percent(interval=None) # FIXME always zero
      mem = process.memory_percent()
      cpu = 0
      if process.pid in last_cpu_time:
        #cpu = (cpu_times.user - last_cpu_time[process.pid]) / config_interval * 100 # load in percent
        cpu = (cpu_times.user - last_cpu_time[process.pid]) / config_interval # load
      # add self to sum
      sum_cpu += cpu
      sum_mem += mem
      sum_rss += rss
      last_cpu_time[process.pid] = cpu_times.user
      for p in process.children():
        child_tree = None
        try:
          # recursion
          child_tree = get_process_tree_slow(p, depth + 1)
          #_pid, _name, _cmdline, _cpu, _mem, _sum_cpu, _sum_mem, _children = get_process_tree(p, depth + 1)
        except psutil.NoSuchProcess as e:
          continue
        # add children to sum
        sum_cpu += child_tree[6]
        sum_mem += child_tree[7]
        sum_rss += child_tree[8]
        children.append(child_tree)
      pid = process.pid
      name = process.name()
      cmdline = process.cmdline()
      process_tree = (pid, name, cmdline, cpu, mem, rss, sum_cpu, sum_mem, sum_rss, children)
      return process_tree
  except psutil.NoSuchProcess as e:
    raise e


ps_fields = ['pid', 'ppid', 'name', 'exe', 'cmdline', 'cwd', 'environ', 'status', 'cpu_times', 'cpu_percent', 'memory_percent', 'memory_info']

def get_process_info(root_process):

  # on a busy machine:
  # cpu usage: 10% to 20%
  # loop time: 1sec to 2sec

  process_info = dict()

  found_root_process = False

  for process in psutil.process_iter(ps_fields):

    pid = process.info["pid"]

    # find start of tree
    if pid == root_process.pid:
      found_root_process = True
      process_info[pid] = process.info

      # TODO refactor
      process_info[pid]["child_pids"] = list()
      process_info[pid]["sum_cpu"] = process_info[pid]["cpu_percent"]
      process_info[pid]["sum_mem"] = process_info[pid]["memory_percent"]
      process_info[pid]["sum_rss"] = process_info[pid]["memory_info"].rss

      #cpu = 0
      #if process.pid in last_cpu_time:
      #  #cpu = (cpu_times.user - last_cpu_time[process.pid]) / config_interval * 100 # load in percent
      #  cpu = (cpu_times.user - last_cpu_time[process.pid]) / config_interval # load

      continue

    if found_root_process == False:
      continue

    # find children of tree
    ppid = process.info["ppid"]
    if ppid in process_info:
      process_info[pid] = process.info

      # TODO refactor
      process_info[pid]["child_pids"] = list()
      process_info[pid]["sum_cpu"] = process_info[pid]["cpu_percent"]
      process_info[pid]["sum_mem"] = process_info[pid]["memory_percent"]
      process_info[pid]["sum_rss"] = process_info[pid]["memory_info"].rss

      process_info[ppid]["child_pids"].append(pid)

  return process_info


def print_process_tree(process_tree, file=sys.stdout, depth=0):
  if depth == 0:
    t = time.strftime("%F %T %z")
    #print(f"\n{'load':<{cpu_width}s} mem rss  vms  proc @ {t}", file=file)
    print(f"\n{'load':<{cpu_width}s} mem rss  proc @ {t}", file=file)
    #print(f"\n{'load':<{cpu_width}s} mem proc @ {t}", file=file)
  (pid, name, cmdline, cpu, mem, rss, sum_cpu, sum_mem, sum_rss, children) = process_tree
  indent = "  "
  #print(f"{sum_cpu:3.0f} {sum_mem:3.0f} {indent * depth}{shlex.join(cmdline)}", file=file)
  #print(f"{sum_cpu:{cpu_width}.0f} {sum_mem:3.0f} {indent * depth}{name}", file=file)
  #print(f"{sum_cpu:{cpu_width}.1f} {sum_mem:3.0f} {Float(rss):4.0h} {Float(vms):4.0h} {indent * depth}{name}", file=file)
  # rss is more precise than mem. mem = rss / total_memory
  print(f"{sum_cpu:{cpu_width}.1f} {sum_mem:3.0f} {Float(sum_rss):4.0h} {indent * depth}{name}", file=file)
  #print(f"{sum_cpu:{cpu_width}.1f} {sum_mem:3.0f} {indent * depth}{name}", file=file)
  depth += 1
  for _process_tree in children:
    print_process_tree(_process_tree, file, depth)

def cumulate_process_info(process_info, root_pid):
  # depth first
  for child_pid in process_info[root_pid]["child_pids"]:
    cumulate_process_info(process_info, child_pid)
    process_info[root_pid]["sum_cpu"] += process_info[child_pid]["sum_cpu"]
    process_info[root_pid]["sum_mem"] += process_info[child_pid]["sum_mem"]
    process_info[root_pid]["sum_rss"] += process_info[child_pid]["sum_rss"]


def print_process_info(process_info, root_pid, file=sys.stdout, depth=0):

  if depth == 0:
    t = time.strftime("%F %T %z")
    #print(f"\n{'load':<{cpu_width}s} mem rss  vms  proc @ {t}", file=file)
    print(f"\n{'load':<{cpu_width}s} mem rss  proc @ {t}", file=file)
    #print(f"\n{'load':<{cpu_width}s} mem proc @ {t}", file=file)

  indent = "  "
  info = process_info[root_pid]
  sum_cpu = info["sum_cpu"] / 100 # = load
  #mem = info["sum_mem"]
  sum_mem = info["sum_mem"]
  sum_rss = info["sum_rss"]
  name = info["name"]
  cmdline = info["cmdline"]
  # value None = psutil.AccessDenied
  exe = info["exe"] # always None
  cwd = info["cwd"] # always None
  environ = info["environ"] # always None
  log_info = {"exe": exe, "cmdline": cmdline, "cwd": cwd, "environ": environ}
  print(f"{sum_cpu:{cpu_width}.1f} {sum_mem:3.0f} {Float(sum_rss):4.0h} {depth*indent}{name} info={repr(log_info)}", file=file)
  for child_pid in process_info[root_pid]["child_pids"]:
    print_process_info(process_info, child_pid, file, depth + 1)


def main():

  root_process = find_root_process(config_root_process_name)

  try:

    while True:

      process_info = get_process_info(root_process)

      cumulate_process_info(process_info, root_process.pid)

      print_process_info(process_info, root_process.pid)

      time.sleep(config_interval)

  except KeyboardInterrupt:
    sys.exit()

if __name__ == "__main__":

  main()
