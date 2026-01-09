install pipewire wireplumber pipewire-audio pipewire-pulse pipewire-alsa

systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service


| Package            | Why you need it |
|--------------------|-----------------|
| pipewire           | The core “multimedia bus.” It handles the routing of audio and video streams. |
| wireplumber        | The session manager. Without this, PipeWire is like a car without a driver; it won’t know which speakers or mics to activate. |
| pipewire-audio     | Provides the necessary files to treat PipeWire as a full-blown system audio server. |
| pipewire-pulse     | Crucial. Most apps (Spotify, Discord, browsers) still look for “PulseAudio.” This package creates a fake PulseAudio server that redirects everything to PipeWire. |
| pipewire-alsa      | Routes very old applications that only understand the low-level ALSA layer into PipeWire. |
