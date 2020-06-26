function sys = adjustTxCenter(sys,txCenterIdx)
sys.txCenterIdx = txCenterIdx;
sys.txCenter = [sys.ax(txCenterIdx(1)),sys.ay(txCenterIdx(2)),sys.az(txCenterIdx(3))];
sys.txImg = displayTxLoc(sys);