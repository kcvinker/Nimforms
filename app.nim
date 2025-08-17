
import Nimforms/nimforms


var frm = newForm("Nimforms GUI Library", 900, 500)
frm.onMouseUp = proc(c: Control, e: MouseEventArgs) = echo "X: " & $e.x & " Y: " & $e.y
frm.createHandle(true)


# Let's create a tray icon
var ti = newTrayIcon("Nimforms tray icon!", "nficon.ico")

# Now add a context menu to our tray icon.
# ti.addContextMenu(TrayMenuTrigger.tmtAnyClick, "Windows", "|", "Linux", "ReactOS")

# Add a click event handler for "Windows" menu.
# let winmenu = ti.contextMenu["Windows"]
# proc onWinmenuClick(c: MenuItem, e: EventArgs) {.handles: winmenu.onClick} = echo "Windows menu selected"


var mbar = frm.addMenubar("Windows", "Linux", "ReactOS")
mbar.menus["Windows"].addItems("Windows 8", "Windows 10", "|", "Windows 11")
mbar.menus["Windows"].menus["Windows 11"].addItem("My OS")

#Let's add a timer control which ticks in each 800 ms.
var tmr = frm.addTimer(800, proc(c: Control, e: EventArgs) = echo "Timer ticked...")


var btn = newButton(frm, "Normal")
btn.onClick = proc(c: Control, e: EventArgs) = 
                ti.showBalloon("Nimform", "Hi from Nimforms", 3000) # Button click will show the balloon 

var btn2 = newButton(frm, "Flat Color", btn->10)
btn2.backColor = 0x83c5be

# btn2.onClick = proc(c: Control, e: EventArgs) = tmr.start() # Button click will start the timer 


var btn3 = newButton(frm, "Gradient", btn2.right(10))
btn3.setGradientColor(0xeeef20, 0x70e000)

#----------------------
var dtp = newDateTimePicker(frm, btn3.right(10))
dtp.font = newFont("Tahoma", 14)
dtp.foreColor = 0xe63946

var cmb = newComboBox(frm, dtp.right(10), w=120)
cmb.addItems("Windows", "MacOS", "Linux", "ReactOS")
cmb.selectedIndex = 0

var gb = newGroupBox(frm, "GroupBox1", 10, btn>>20, 120, 150)
gb.backColor = 0xa8dadc

var lb = newLabel(frm, "Static Text", 20, gb.ypos + 30)
lb.printControlRect()
# lb.foreColor = 0x7b2cbf
gb.addControls(lb)

var lbx = newListBox(frm, gb.right(20), btn.bottom(20))
lbx.addItems("Windows", "Linux", "MacOS", "ReactOS")

var lv = newListView(frm, lbx.right(10), btn.bottom(20), ("Windows", "Linux", "MacOS", 100, 100, 110))
lv.addRow("Win7", "openSUSE", "Mojave")
lv.addRow("Win8", "Debian:", "Catalina")
lv.addRow("Win10", "Fedora", " Big Sur")
lv.addRow("Win11", "Ubuntu", "Monterey")



var np = newNumberPicker(frm, 20, lb.bottom(20))
np.decimalDigits = 2
np.step = 0.5

var np2 = newNumberPicker(frm, 20, np.bottom(10))
np2.buttonLeft = true
np2.backColor = 0xffbf69

var gb2 = newGroupBox(frm, "Compiler Options", 10, gb.bottom(20), 180, 170) #, GroupBoxStyle.gbsOverride)
# gb2.style = GroupBoxStyle.gbsOverride
gb2.setForeColor(0xd90429)

gb2.changeFont("Trebuchet MS", 12)

var cb = newCheckBox(frm, "Threads On", gb2.xpos + 20, gb2.ypos + 40)
var cb2 = newCheckBox(frm, "Hints off", gb2.xpos + 20, cb.bottom(10))
var rb = newRadioButton(frm, "Consoe App", gb2.xpos + 20, cb2.bottom(10))
var rb2 = newRadioButton(frm, "GUI App", gb2.xpos + 20, rb.bottom(10))
rb2.foreColor = 0xff0054

var tb = newTextBox(frm, "Enter text", gb2.right(20), gb.bottom(40))

var tkb = newTrackBar(frm, gb2.right(20), tb.bottom(20)) #, cdraw = true)
tkb.ticColor = 0xFF0012
var pgb = newProgressBar(frm, gb2.right(20), tkb.bottom(20), perc=true )

var tv = newTreeView(frm, pgb.right(20), lv.bottom(20), h=200)
tv.addTreeNodeWithChilds("Windows", "Win7", "Win8", "Win10", "Win11")
tv.addTreeNodeWithChilds("Linux", "openSUSE Leap 15.3", "Debian 11", "Fedora 35", "Ubuntu 22.04 LTS")
tv.addTreeNodeWithChilds("MacOS", "Mojave (10.14)", "Catalina (10.15)", " Big Sur (11.0)", "Monterey (12.0)")


var cal = newCalendar(frm, cmb.right(25), 10)



proc onTrackChange(c: Control, e: EventArgs) {.handles:tkb.onValueChanged.} =
    pgb.value = tkb.value


proc flatBtnClick(c: Control, e: EventArgs) =
    # frm.backColor= 0xe63946
    frm.setGradientBackColor(0xe85d04, 0xffba08)
btn2.onClick = flatBtnClick

var cmenu = lv.setContextMenu("Add Work", "Give Work", "Finish Work")
let aw = cmenu["Add Work"]

proc addWork(m: MenuItem, e: EventArgs) {.handles: aw.onClick} = echo "Add Work menu clicked"

# var lb5 = newLabel(frm, "Testing", 22, 100)



# echo "Program starts "
frm.display()

