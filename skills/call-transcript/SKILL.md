---
name: call-transcript
description: Read the transcripts of the user's Discord voice calls. Use when the user refers to a call, a voice chat, or what someone said on Discord, for example "summarize the call", "what did they say about X", or "in the call earlier".
---

# Discord call transcripts

CallScribe writes one Markdown file for each Discord call in `D:\CallScribe\transcripts`.
The file name is the start time of the call: `YYYY-MM-DD_HHMMSS.md`. The file with the
highest name is the latest call. To find it:

    Get-ChildItem D:\CallScribe\transcripts -Filter *.md | Sort-Object Name | Select-Object -Last 1

Each line of speech has this form: `- [HH:MM:SS] Speaker: text`.

- `Me` is the user's microphone.
- `Them` is the speaker that Discord plays to. It holds all the other people on the call,
  and it does not tell them apart. It also holds other sound on that speaker, for example
  a video.

The file grows during the call. The line `Call ended HH:MM:SS.` shows that the call is
finished.

Speech recognition makes mistakes, mostly with names and rare words. When one word is
important, tell the user that the word can be wrong.

If a call has no transcript, read `watch.log` and `record.log` in `W:\src\callscribe`.
