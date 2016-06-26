# timelinefx.monkey2

TimelineFX is a particle effects module for Monkey 2 programming language (https://github.com/blitz-research/monkey2)

Current status of this module is that so far only the collision part of it is implemented, particles will follow next! The collision 
module should be fully working now, you can find a few examples in the samples folder with plenty of documentation.

###Installation
Clone into your Monkey2 modues folder under timelinefx. In a command prompt/terminal cd to monkey2/bin and type:

Windows:
`mx2cc_windows makemods timelinefx`

Mac:
`./mx2cc_macos makemods timelinefx`

Linux:
`./mx2cc_linux makemods timelinefx`

To compile in release use the -config=release option like so:
`mx2cc_windows makemods -config=release timelinefx`
