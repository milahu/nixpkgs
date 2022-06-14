#!/usr/bin/env python3

print("trying to import PyQt6.QtCore")
import PyQt6.QtCore
print("PyQt6.QtCore", PyQt6.QtCore)

print("trying to import PyQt6.QtWidgets")
import PyQt6.QtWidgets
print("PyQt6.QtWidgets", PyQt6.QtWidgets)

print("trying to import PyQt6.QtGui")
import PyQt6.QtGui
print("PyQt6.QtGui", PyQt6.QtGui)

print("trying to import PyQt6.QtQml")
import PyQt6.QtQml
print("PyQt6.QtQml", PyQt6.QtQml)

import sys

#from PyQt6.QtCore import *
#from PyQt6.QtGui import *
from PyQt6.QtWidgets import *

app = QApplication(sys.argv)

w = QWidget()
b = QLabel(w)
b.setText("hello")
w.setGeometry(100, 100, 200, 50)
b.move(50, 20)
w.setWindowTitle("pyqt")
w.show()

#sys.exit(app.exec())
app.exec(); del app
