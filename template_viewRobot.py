#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# INSTALL PySide2 (QT for Python)
# pip install PySide2
#
# INSTALL Qt Quick 3D
# sudo apt-get install -y qml-module-qtquick-scene3d
#
# This code is from following URL,
# and is all right reserved by
# https://doc.qt.io/qt-5/qtquick3d-simple-example.html
#

import sys
import os
import time

from PySide2 import QtCore, QtWidgets, QtGui, QtQml

g_jointNum = 15

# GUIの基本MVC (Model,View,Control) のうち、スレッドで走るコントロールクラス。
# ロボットの状態をシグナルで送る
class Manager(QtCore.QObject):
    dataReady = QtCore.Signal( ('QVariantList', 'bool'), name='dataReady')

    def __init__(self, parent=None):
        super(Manager, self).__init__(parent)
        # 現在の関節角指令値
        self._angles = [0.0] * g_jointNum
        # サーボロック状態(Trueなら正常,Falseなら一旦停止(サーボロック)状態)
        self._isServoUnLock = True
        #
        self._xIncrement = 0
        self._xIncrement_witin_360 = 0
        self._delay = 0.1
        self._starter = True
        self._goOn = True
        self._threader = None

    @QtCore.Property(bool)
    def starter(self):
        return self._starter

    @starter.setter
    def setStarter(self, val):
        print(val)
        if val:
            self.start()
        else:
            self.stop()
        self._starter = val

    @QtCore.Property(float)
    def delay(self):
        return self._delay

    @delay.setter
    def setDelay(self, val):
        if self._delay == val:
            return
        print(val)
        self._delay = val

    @QtCore.Property(float)
    def xIncrement(self):
        return self._xIncrement

    @xIncrement.setter
    def setXIncrement(self, val):
        if self._xIncrement == val:
            return
        print(val)
        self._xIncrement = val

    def generateAngles(self):
        global rbt
        try:
            # 関節角情報取得
            self._angles = [0.0] * g_jointNum # ここに現在関節角度取得の処理を書きます
            # 一旦停止(サーボロック)状態かどうかの状態取得
            servoStatus =  True # ここに状態取得の処理を書きます
            if ( servoStatus ):
                # 通常状態(サーボアンロック状態)
                self._isServoUnLock = True
            else:
                # 一旦停止状態(サーボロック状態)
                self._isServoUnLock = False
        except:
            time.sleep(5)
        return self._angles, self._isServoUnLock

    def stop(self):
        self._goOn = False
        if self._threader is not None:
            while self._threader.isRunning():
                time.sleep(0.1)

    def start(self):
        self._goOn = True
        self._threader = Threader(self.core, self)
        self._threader.start()

    def core(self):
        while self._goOn:
            angles, isServoUnLock = self.generateAngles()
            self.dataReady.emit(angles, isServoUnLock)
            time.sleep(self._delay)

# -------------------------------------------------

# スレッド生成・実行用のユーティリティクラス
# 上のManagerクラスで使用
class Threader(QtCore.QThread):
    def __init__(self,core,parent=None):
        super(Threader, self).__init__(parent)
        self._core = core

    def run(self):
        self._core()

# -------------------------------------------------



if __name__ == '__main__':
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Material"

    format = QtGui.QSurfaceFormat()
    format.setVersion(3, 3);
    QtGui.QSurfaceFormat.setDefaultFormat(format);
    app = QtWidgets.QApplication(sys.argv)

    # SignalによりQML側に本スクリプトの計算結果を投げ続ける
    manager = Manager()
    app.aboutToQuit.connect(manager.stop)
    manager.start()
    engine = QtQml.QQmlApplicationEngine()
    ctx = engine.rootContext()
    ctx.setContextProperty("Manager", manager)

    # GUIの基本MVC (Model,View,Control) のうち、
    # Model(画面構成)とViewを持つQMLをロード。
    # (ロボットのモデル情報は全てobjファイルにて定義)
    engine.load( QtCore.QUrl("qml/load_NX01_model.qml") )
    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec_())
