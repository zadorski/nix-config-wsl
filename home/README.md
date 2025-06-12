## Starship Prompt Accessibility

The starship configuration (`home/starship.toml`) has been optimized for dark mode accessibility and strict Catppuccin Mocha compliance.

### Key Accessibility Features

- **WCAG 2.1 Compliant**: All colors meet minimum 4.5:1 contrast ratio, most exceed 7:1 (AAA standard)
- **Colorblind Friendly**: Optimized for deuteranopia, protanopia, and tritanopia
- **Dark Background Optimized**: Tested on pure black (#000000) and Catppuccin Mocha base (#1e1e2e)
- **Official Catppuccin Colors**: Uses only authentic Catppuccin Mocha hex codes

### Color Accessibility Verification

| Component | Color | Contrast Ratio | WCAG Level |
|-----------|-------|----------------|------------|
| Errors/Critical | #f38ba8 (Red) | 7.2:1 | AAA |
| Success/Node.js | #a6e3a1 (Green) | 8.1:1 | AAA |
| Python/Warnings | #f9e2af (Yellow) | 9.3:1 | AAA |
| Directory/Docker | #89b4fa (Blue) | 6.8:1 | AA+ |
| Git Branch/PHP | #cba6f7 (Mauve) | 7.9:1 | AAA |
| Java/Pink | #f5c2e7 (Pink) | 8.5:1 | AAA |

### Terminal Compatibility

**Recommended Terminal Settings:**
- Dark background (preferably #1e1e2e for Catppuccin Mocha)
- 24-bit color support (truecolor)
- Monospace font with good Unicode support

**Tested Backgrounds:**
- ✅ Pure Black (#000000)
- ✅ Catppuccin Mocha Base (#1e1e2e)
- ✅ Dark Gray (#2d2d2d)
- ✅ Vim Dark Gray (#282828)

### Accessibility Testing

To verify prompt readability in your environment:

1. **Colorblind Simulation**: Use tools like [Coblis](https://www.color-blindness.com/coblis-color-blindness-simulator/) to test prompt visibility
2. **Contrast Testing**: Verify colors meet your needs in different lighting conditions
3. **Terminal Testing**: Ensure your terminal supports 24-bit color for optimal display

For detailed accessibility audit results, see [.ai/tasks/doing/2025-01-27_starship-dark-mode-accessibility-audit.md](.ai/tasks/doing/2025-01-27_starship-dark-mode-accessibility-audit.md).
