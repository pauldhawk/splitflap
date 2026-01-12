# Getting Started with KiCad - Beginner's Guide

**Project:** Chainlink Driver TMC2209
**Your Goal:** Modify schematic for NEMA 17 + TMC2209 motors

---

## ✅ KiCad is Now Open

You should see the **KiCad Project Manager** window.

---

## Step 1: Open the Schematic

1. In the KiCad window, look for the file list on the left
2. Find `chainlinkDriver_TMC2209.sch`
3. **Double-click** it to open the **Schematic Editor**

A new window will open showing the circuit diagram.

---

## Step 2: Understanding the KiCad Schematic Interface

### Top Toolbar (Important Buttons)
```
🔍 Zoom In/Out
✋ Pan tool
➕ Place symbol
📏 Measure
🔌 Add wire
🏷️  Add label
```

### Mouse Controls
- **Scroll wheel:** Zoom in/out
- **Middle-click drag:** Pan around
- **Left-click:** Select
- **Right-click:** Context menu

### Keyboard Shortcuts (Important!)
- **E:** Edit selected item
- **M:** Move selected item
- **Delete:** Remove selected item
- **Esc:** Cancel current action
- **Ctrl+Z:** Undo
- **Ctrl+S:** Save

---

## Step 3: Your First Edit - Remove U7 (Third Shift Register)

Let's start with something simple: deleting the third 74HC595 chip (U7).

### Finding U7

1. Press **Ctrl+F** (Find)
2. Type: `U7`
3. Press Enter
4. KiCad will zoom to U7 (a rectangular chip symbol)

### Deleting U7

1. **Click on U7** to select it (it will turn yellow/highlighted)
2. Press **Delete** key
3. **Warning:** Connected wires will remain! We need to delete those too.

### Deleting Connected Wires

1. **Click and drag** to select a box around U7's area
2. This will select U7 + all nearby wires and labels
3. Press **Delete**
4. Confirm deletion

**You've made your first change!** 🎉

---

## Step 4: Your Second Edit - Change a Label

Now let's change `MOTOR_A_PHASE_A` to `MOTOR_A_STEP`.

### Finding the Label

1. Press **Ctrl+F**
2. Type: `MOTOR_A_PHASE_A`
3. Press Enter

### Editing the Label

1. **Click on the label** to select it
2. Press **E** (Edit)
3. A dialog box will appear with the current text
4. Change `MOTOR_A_PHASE_A` to `MOTOR_A_STEP`
5. Click **OK**

**Great! You changed a label!** 🎉

---

## Step 5: Save Your Work

**IMPORTANT:** Save frequently!

1. Press **Ctrl+S** (Save)
2. Or: File → Save

---

## Step 6: Understanding the Next Steps

You've learned:
- ✅ How to find components
- ✅ How to delete things
- ✅ How to edit labels
- ✅ How to save

**Next, you'll:**
- Change all the PHASE labels to STEP/DIR
- Delete the ULN2003A chips
- Add TMC2209 symbols

---

## Quick Reference Card

### Common Actions
| Action | How To |
|--------|--------|
| Select item | Left-click |
| Move item | Click item, press M, move mouse, click to place |
| Edit item | Click item, press E |
| Delete item | Click item, press Delete |
| Add wire | Press A (Add), select Wire |
| Add label | Press A, select Label |
| Find component | Ctrl+F |
| Undo | Ctrl+Z |
| Save | Ctrl+S |
| Zoom to fit | Home key |

### Navigation
- **Scroll wheel:** Zoom
- **Middle-click drag:** Pan
- **Home:** Zoom to fit all

---

## If You Get Stuck

**Problem:** Can't find a component
- **Solution:** Press Ctrl+F and type the reference (like U7)

**Problem:** Deleted wrong thing
- **Solution:** Press Ctrl+Z to undo

**Problem:** Schematic looks messy
- **Solution:** Press Home to zoom to fit everything

**Problem:** Not sure what to do next
- **Solution:** Open SCHEMATIC_CHANGES.md and follow Section by Section

---

## Ready for More?

You now know the basics! Here's what to do next:

### Option A: Continue Step-by-Step (Recommended)
Follow `SCHEMATIC_CHANGES.md` starting at **Section 1.2**

### Option B: Let Me Know When You're Ready
Take a screenshot of your KiCad window and I can guide you through the next specific steps!

### Option C: Watch a Quick Tutorial
Search YouTube: "KiCad schematic editing basics" (~10 minute videos)

---

## Progress Checklist

Track your progress as you work:

- [ ] Opened schematic successfully
- [ ] Found and deleted U7
- [ ] Changed one PHASE label to STEP
- [ ] Saved the file
- [ ] Ready to continue with more changes

---

**You're doing great!** Take it one step at a time. PCB design is a skill that gets easier with practice.

**When ready:** Let me know what section you're on and I'll help if you get stuck!
