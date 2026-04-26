# Plymouth: IO boot splash

Files:

| File          | Purpose                                                                         |
|---------------|---------------------------------------------------------------------------------|
| `io.plymouth` | Theme manifest — points Plymouth at the script and image directory.             |
| `io.script`   | Plymouth scripting language: navy gradient background + pulsing centred logo + amber progress bar. |
| `logo.png`    | **Generated, not committed.** Run `branding/icons/generate-pngs.sh` and copy `png/io-logo-256.png` here as `logo.png`. |

## Install path inside the image

```
/usr/share/plymouth/themes/io/
├── io.plymouth
├── io.script
└── logo.png
```

Switch to it at first boot via:

```sh
plymouth-set-default-theme -R io
```

## Why scripted instead of `spinner`

`spinner` is simpler but doesn't give us a pulsing logo + a slim progress
bar in one theme. The script is short enough that the cost is acceptable.
