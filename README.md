# Nimforms
A simple gui library for Nim programming language based on Windows API

## Screenshots
All controls
![image](https://user-images.githubusercontent.com/8840907/231178800-fcac000f-452d-4a9b-a7f1-810b7e31b03a.png)

## How to use:
1. Clone or download the repo.
2. Place the **Nimforms** folder in your project folder.
3. Import **Nimforms/nimforms** module in your source file. And start coding. 


## Sample code
This is the code that created the window in above screenshot
```nim

import Nimforms/nimforms

var frm = newForm("Nimforms GUI Library", 860)
frm.onMouseUp = proc(c: Control, e: MouseEventArgs) = echo "X: " & $e.x & " Y: " & $e.y
frm.createHandle()

var btn = newButton(frm, "Normal")
btn.createHandle()

var btn2 = newButton(frm, "Flat Clr", 130)
btn2.backColor = 0xffb4a2
btn2.createHandle()

var btn3 = newButton(frm, "Gradient", 250)
btn3.setGradientColor(0xeeef20, 0x70e000)
btn3.createHandle()

var cb = newCheckBox(frm, "Check this", 10, 60)
cb.createHandle()

var cmb = newComboBox(frm, 110, 60)
cmb.addItems("Window", "MacOs", "Linux", 4500)
cmb.createHandle()

var dtp = newDateTimePicker(frm, 265, 60)
dtp.createHandle()

var gb = newGroupBox(frm, "GroupBox1", 10, 100)
gb.createHandle()

var lb = newLabel(frm, "Static Text", 370, 15)
lb.foreColor = 0x7b2cbf
lb.createHandle()

var lbx = newListBox(frm, 175, 100)
lbx.createHandle()
lbx.addItems("Windows", "Linux", "MacOS", "ReactOS")

var lv = newListView(frm, 320, 100, w = 280)
lv.createHandle()
lv.addColumns(@["Names", "Jobs", "Salaries"], @[75, 100, 80])
# lv.addColumns(3, "Names", "Jobs", "Salaries", 100, 60, 110)
# lv.addColumns("Names", "Jobs", "Salaries", 100, 60, 110)

lv.addRow("Johnson", "Translator", 45000)
lv.addRow("Maria", "Clerk", 17500)
lv.addRow("Philip", "Accountant", 32000)

var np = newNumberPicker(frm, 23, 135)
np.decimalDigits = 2
np.step = 0.5
np.createHandle()

var np2 = newNumberPicker(frm, 23, 175)
np2.buttonLeft = true
np2.backColor = 0xffbf69
np2.createHandle()

var rb = newRadioButton(frm, "Radio 1", 460, 20)
rb.createHandle()

var rb2 = newRadioButton(frm, "Radio 2", 460, 50)
rb2.foreColor = 0xff0054
rb2.createHandle()

var tb = newTextBox(frm, "Text box", 23, 213)
tb.createHandle()

var tkb = newTrackBar(frm, 20, 265)
tkb.customDraw = true
tkb.createHandle()

var tv = newTreeView(frm, 600, 20)
tv.height = 120
tv.createHandle()
var n1 = tv.addNode("Windows")
var n2 = tv.addNode("Linux")
tv.addChildNode("Win 7", n1)
tv.addChildNode("Uduntu", n2)
var w8 = newTreeNode("Win 8")
tv.nodes[0].addChildNode(w8)
w8.addChildNode("Win 8.1")

var pb = newProgressBar(frm, 20, 324)
pb.showPercentage = true
pb.createHandle()

var cal = newCalendar(frm, 600, 156)
cal.createHandle()

proc btnClick(c: Control, e: EventArgs) =
    pb.value = 24
    echo "Progressbar value set"

btn.onClick = btnClick
frm.display() # This will display the form

```
