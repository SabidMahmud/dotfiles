# Appearance picker

This is the on-demand Quickshell frontend for `theme-switch`.
Launch it through `theme`, `theme wallpaper`, `theme browse` (alias `theme all-wallpapers`), or `theme --gui` so the backend
path and initial view are supplied. No startup entry or systemd service is needed.

The gallery inherits the current theme's colours from `themes/<name>/waybar.css`
and refreshes them after applying a selection. Its transparent overlay,
monospace text, outlined labels, and accent border keep the wallpaper central;
it does not define a separate desktop palette.
Its carousel adapts the geometry and image masks from
[Omarchy's Quickshell picker](https://github.com/omacom/omarchy/blob/84b3f2872b5023c13967543ed4a98b08fcac5b21/shell/plugins/image-picker/ImagePicker.qml):
a 768 × 475 centre preview, 108 × 432 neighbouring slices, a 28-pixel skew,
and 30-pixel overlap. These dimensions scale down on smaller screens. The
upstream notice is preserved in [OMARCHY-LICENSE](OMARCHY-LICENSE), including
the copyright credit to David Heinemeier Hansson. Credit for the upstream
picker goes to [Omarchy](https://omarchy.org/), created by
[DHH](https://dhh.dk/), and the Omarchy contributors. The local launcher,
Sway integration, and wallpaper-to-preset matching adapt it to these dotfiles.

Left / Right, Up / Down, and Tab / Shift+Tab browse, typing filters, and
Ctrl+F focuses the filter. Enter or Apply applies the selected item.
Click a neighbouring slice to select it, then the centre preview to apply.
The Themes / Wallpapers / All wallpapers controls and Ctrl+1 / Ctrl+2 / Ctrl+3 change views.
All wallpapers groups images by preset and shows each image's matching preset
name. Its **Apply wallpaper + theme** action switches both the preset and the
exact wallpaper in one pass; choosing
another image from the active preset updates only the wallpaper. The current
theme's Wallpapers view retains its original behaviour. Type either a wallpaper
name or preset name to filter the collection. `theme --cli browse` offers the
same preset matching through the terminal picker.
Applying keeps the gallery open. Escape, Close, or clicking outside the gallery
exits; closing during an apply waits for that operation to complete before exiting.

The Python helper `bin/dot-local/bin/theme-picker` discovers themes, validates
selections, streams optional 960 × 600 ImageMagick thumbnails, and calls the existing
switcher with argument arrays. All wallpapers selections carry both the owning
preset and exact image; ownership is validated before changing theme or wallpaper
state. It uses a file lock to prevent duplicate galleries.
Source wallpapers are never modified. Qt image loading is asynchronous and
limited to preview dimensions even before a cached thumbnail is ready. The
selected image loads before neighbours, off-screen slices release their image
layers, and the thumbnail worker exits when the gallery closes. Carousel movement
uses 140 ms transitions; set `THEME_PICKER_REDUCED_MOTION=1` to disable them.

Keep the picker focused to compare themes, or close it to inspect the entire
desktop. Escape closes without changing the last successfully applied selection.
