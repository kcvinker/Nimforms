
import Nimforms/nimforms

# Create a Form
var frm = newForm("Nimforms GUI Library", 960, 600)
frm.printPoint() # It's handy in design time, we can get the coordinates by clicking on the form.
frm.createHandle(create_childs=true) # Child windows will create their handle autmatically.

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

# Now, create a ComboBox and add some items.
var cmb = newComboBox(frm, dtp.right(10), w=120)
cmb.addItems("Windows", "MacOS", "Linux", "ReactOS")
cmb.selectedIndex = 0 # First item is selected

#Let's create a Calendar next.
var cal = newCalendar(frm, cmb.right(25), 10)

# Let's create a GroupBox. `>>` macro will get btn.right + 20
var gb = newGroupBox(frm, "GroupBox1", 10, btn>>20, 120, 150)
gb.backColor = 0xa8dadc

# Now, a Label.
var lb = newLabel(frm, "Static Text", 20, gb.ypos + 30)
lb.printControlRect()
# lb.foreColor = 0x7b2cbf
gb.addControls(lb)

# Let's create a ListBox and put some items.
var lbx = newListBox(frm, gb.right(20), btn.bottom(20))
lbx.addItems("Windows", "Linux", "MacOS", "ReactOS")

# Now, create a ListView and add some items and it's sub items.
# Constructor takes column names and column widths.
var lv = newListView(frm, lbx.right(10), btn.bottom(20), ("Windows", "Linux", "MacOS", 100, 100, 110))
lv.addRow("Win7", "openSUSE", "Mojave")
lv.addRow("Win8", "Debian:", "Catalina")
lv.addRow("Win10", "Fedora", " Big Sur")
lv.addRow("Win11", "Ubuntu", "Monterey")

# This is the NumberPicker aka UpDown control in .NET
var np = newNumberPicker(frm, 20, lb.bottom(20))
np.decimalDigits = 2
np.step = 0.5

var np2 = newNumberPicker(frm, 20, np.bottom(10))
np2.buttonLeft = true
np2.backColor = 0xffbf69

# We are changing the drawing style of this GroupBox.
var gb2 = newGroupBox(frm, "Compiler Options", 10, gb.bottom(20), 180, 170, GroupBoxStyle.gbsOverride)
gb2.setForeColor(0xd90429)
gb2.changeFont("Trebuchet MS", 12)

# Now create a PictureBox and set an image.
var pbx = newPictureBox(frm, 640, 233, 285, 200, "nvidia-com.png", PictureSizeMode.psmStretch)

# Add some CheckBoxes and RadioButtons.
var cb = newCheckBox(frm, "Threads On", gb2.xpos + 20, gb2.ypos + 40)
var cb2 = newCheckBox(frm, "Hints off", gb2.xpos + 20, cb.bottom(10))
var rb = newRadioButton(frm, "Consoe App", gb2.xpos + 20, cb2.bottom(10))
var rb2 = newRadioButton(frm, "GUI App", gb2.xpos + 20, rb.bottom(10))
rb2.foreColor = 0xff0054

# Let's add a TextBox
var tb = newTextBox(frm, "Enter text", gb2.right(20), gb.bottom(40))

# Now, create a TrackBar.
var tkb = newTrackBar(frm, gb2.right(20), tb.bottom(20)) #, cdraw = true)
tkb.channelStyle = ChannelStyle.csOutline

# Let's add a ProgressBar
var pgb = newProgressBar(frm, gb2.right(20), tkb.bottom(20), perc=true )

# Last but not least, we are creating a TreeView and some nodes.
var tv = newTreeView(frm, pgb.right(20), lv.bottom(20), h=200)
tv.addTreeNodeWithChilds("Windows", "Win7", "Win8", "Win10", "Win11")
tv.addTreeNodeWithChilds("Linux", "openSUSE Leap 15.3", "Debian 11", "Fedora 35", "Ubuntu 22.04 LTS")
tv.addTreeNodeWithChilds("MacOS", "Mojave (10.14)", "Catalina (10.15)", " Big Sur (11.0)", "Monterey (12.0)")

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

# Finally, display the form.
frm.display()

