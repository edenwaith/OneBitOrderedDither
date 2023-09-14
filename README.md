# OneBitOrderedDither
A 1-Bit Ordered Dither plug-in for the [Acorn](https://flyingmeat.com/acorn/) image editor

!["Moraine Lake with 1-bit ordered dither"](Moraine_Lake_dithered_16x16.png "Moraine Lake with 1-bit ordered dither")

This Acorn plug-in converts an image into a black & white image using a 16x16 Bayer pattern for the ordered dithering.  The distinctive pattern is reminiscent of gradients used in games like The Secret of Monkey Island.  This plug-in is useful for 1-bit displays, such as for the [Playdate](https://play.date).

## To install:
- Build the project
- Find the plug-in: `Product > Show Build Folder in Finder` and then dig into the folders to find the file `OneBitOrderedDither.acplugin`
- Copy the file `OneBitOrderedDither.acplugin` into the folder `~/Library/Application Support/Acorn/Plug-Ins`

## To run:
- Open a file in Acorn
- Select the menu `Filter > Color Adjustment > 1-Bit Ordered Dither`
