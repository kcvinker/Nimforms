
import Nimforms/nimforms

# Create a Form
var frm = newForm("Nimforms GUI Library", 980, 600)
frm.printPoint() # It's handy in design time, we can get the coordinates by clicking on the form.


# Let's create a tray icon and it's context menu
var ti = newTrayIcon("Nimforms tray icon!", "nficon.ico")
ti.addContextMenu(false, TrayMenuTrigger.tmtAnyClick, "Show Balloon", "Test Me", "Exit")

# Now, create a MenuBar and add menu items.
var mbar = frm.addMenubar(true, "Windows", "Linux", "ReactOS")
mbar.menus["Windows"].addItems("Windows 8", "Windows 10", "|", "Windows 11")
mbar.menus["Windows"].menus["Windows 11"].addItem("My OS")

#Let's add a timer control which ticks in each 800 ms.
var tmr = frm.addTimer(800, proc(c: RootRef, e: EventArgs) = echo "Timer ticked...")

# Now, create some buttons.
var btn = newButton(frm, "Normal")
btn.onClick = proc(c: RootRef, e: EventArgs) = # Button click will show the balloon
                ti.showBalloon("Nimform", "Hi from Nimforms", 3000)  

# This button has a different back color.
var btn2 = newButton(frm, "Flat Color", btn->10)
btn2.backColor = 0x83c5be

# This is a gradient button.
var btn3 = newButton(frm, "Gradient", btn2.right(10))
btn3.setGradientColor(0xeeef20, 0x70e000)

# Now, create a DateTimePicker
var dtp = newDateTimePicker(frm, btn3.right(10))
dtp.font = newFont("Tahoma", 14) # Set a different font.
dtp.backColor=0xe63946
# Now, create a ComboBox and add some items.
var cmb = newComboBox(frm, 530, w=120, enableInput=true)
cmb.addItems("Windows", "MacOS", "Linux", "ReactOS")
cmb.selectedIndex = 0 # First item is selected


# Let's create a GroupBox. `>>` macro will get btn.right + 20
var gb = newGroupBox(frm, "Compiler Options", 10, btn.bottom(20), 270, 150)
gb.backColor = 0xa8dadc

# Now, a Label.
var lb = newLabel(gb, "Thread Count", 10, 40)
# lb.printControlRect()
lb.foreColor = 0x7b2cbf
# gb.addControls(lb)

# Let's create a ListBox and put some items.
var lbx = newListBox(frm, gb.right(20), btn.bottom(20))
lbx.addItems("Windows", "Linux", "MacOS", "ReactOS")

# Now, create a ListView and add some items and it's sub items.
# Constructor takes column names and column widths.
var lv = newListView(frm, lbx.right(10), btn.bottom(20))
lv.addColumns(@["Windows", "Linux", "MacOS"], @[100, 100, 110])

lv.addRow("Win7", "openSUSE", "Mojave")
lv.addRow("Win8", "Debian:", "Catalina")
lv.addRow("Win10", "Fedora", " Big Sur")
lv.addRow("Win11", "Ubuntu", "Monterey")

#Let's create a Calendar next.
var cal = newCalendar(frm, 667, 242)

# This is the NumberPicker aka UpDown control in .NET
var np = newNumberPicker(gb, 115, 35)
# np.decimalDigits = 2
# np.step = 0

var lb2 = newLabel(gb, "verbosity", 10, 70)
var np2 = newNumberPicker(gb, 115, 70)
np2.buttonLeft = true
np2.backColor = 0xffbf69

var lb3 = newLabel(gb, "GC Mode", 10, 114)
var cmb2 = newComboBox(gb, 115, 110)
cmb2.addItems("refc", "markAndSweep", "boehm", "arc", "orc", "atomicArc")
cmb2.selectedIndex = 1

# We are changing the drawing style of this GroupBox.
var gb2 = newGroupBox(frm, "Program Options", 10, gb.bottom(20), 200, 170)
gb2.setForeColor(0xd90429)
gb2.changeFont("Trebuchet MS", 14)

# Now create a PictureBox and set an image.
var pbx = newPictureBox(frm, 640, 233, 285, 200, "nvidia-com.png", PictureSizeMode.psmStretch)

# Add some CheckBoxes and RadioButtons.
var cb = newCheckBox(gb2, "Stack Traced On", 10, 40)
var cb2 = newCheckBox(gb2, "Hints off", 10, 70)
var rb = newRadioButton(gb2, "Consoe App", 10, 100)
var rb2 = newRadioButton(gb2, "GUI App", 10, 130)
rb2.foreColor = 0xff0054
rb2.checked = true
cb2.checked = true

var lb4 = newLabel(frm, "Output Name", 10, 425)

# Let's add a TextBox
var tb = newTextBox(frm, "", 120, 425, w=200)
tb.cueBanner = "Enter output name"

# Now, create a TrackBar.
var tkb = newTrackBar(frm, 222, 253) #, cdraw = true)
tkb.channelStyle = ChannelStyle.csOutline
tkb.ticColor = 0x000000

# Let's add a ProgressBar
var pgb = newProgressBar(frm, 220, 325, perc=true )

# Last but not least, we are creating a TreeView and some nodes.
var tv = newTreeView(frm, 453, 237, h=200)
tv.addTreeNodeWithChilds("Windows", "Win7", "Win8", "Win10", "Win11")
tv.addTreeNodeWithChilds("Linux", "openSUSE Leap 15.3", "Debian 11", "Fedora 35", "Ubuntu 22.04 LTS")
tv.addTreeNodeWithChilds("MacOS", "Mojave (10.14)", "Catalina (10.15)", " Big Sur (11.0)", "Monterey (12.0)")
# tv.createHandle()
proc onTrackChange(c: RootRef, e: EventArgs) {.handles:tkb.onValueChanged.} =
    var t11 = cast[TrackBar](c) 
    pgb.value = t11.value


proc flatBtnClick(c: RootRef, e: EventArgs) =
    let fod = newFileOpenDialog("Select files", "", "PDF Files|*.pdf", true)
    if fod.showDialog(frm.handle):
        echo "Selected file(s): "
        for f in fod.fileNames:
            echo f
        
btn2.onClick = flatBtnClick

var cmenu = lv.setContextMenu("Add Work", "Give Work", "Finish Work")
let aw = cmenu["Add Work"]

proc addWork(m: RootRef, e: EventArgs) {.handles: aw.onClick} = echo "Add Work menu clicked"

proc menter(c: RootRef, e: EventArgs) {.handles:np.onMouseEnter.} =
    echo "mouse entered" 

proc mleave(c: RootRef, e: EventArgs) {.handles:np.onMouseLeave.} =
    echo "mouse left" 

proc mhover(c: RootRef, e: EventArgs) {.handles:pbx.onMouseHover.} =
    echo "pbx mouse hovered..." 

# Finally, display the form.
frm.display()

