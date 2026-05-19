---
name: Creative Velocity
colors:
  surface: '#f8f9ff'
  surface-dim: '#d7dae1'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f3fb'
  surface-container: '#ebeef5'
  surface-container-high: '#e5e8ef'
  surface-container-highest: '#e0e2ea'
  on-surface: '#181c21'
  on-surface-variant: '#4b4455'
  inverse-surface: '#2d3136'
  inverse-on-surface: '#eef1f8'
  outline: '#7c7387'
  outline-variant: '#cdc2d8'
  surface-tint: '#7b26e6'
  primary: '#6200c5'
  on-primary: '#ffffff'
  primary-container: '#7d2ae8'
  on-primary-container: '#e7d5ff'
  inverse-primary: '#d6baff'
  secondary: '#00696e'
  on-secondary: '#ffffff'
  secondary-container: '#5ff4fc'
  on-secondary-container: '#006e72'
  tertiary: '#87007e'
  on-tertiary: '#ffffff'
  tertiary-container: '#b000a4'
  on-tertiary-container: '#ffcef0'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ecdcff'
  primary-fixed-dim: '#d6baff'
  on-primary-fixed: '#280057'
  on-primary-fixed-variant: '#5f00bf'
  secondary-fixed: '#63f7ff'
  secondary-fixed-dim: '#3cdae2'
  on-secondary-fixed: '#002021'
  on-secondary-fixed-variant: '#004f53'
  tertiary-fixed: '#ffd7f2'
  tertiary-fixed-dim: '#ffacec'
  on-tertiary-fixed: '#390035'
  on-tertiary-fixed-variant: '#83007a'
  background: '#f8f9ff'
  on-background: '#181c21'
  surface-variant: '#e0e2ea'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '800'
    lineHeight: '1.1'
    letterSpacing: -0.04em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.2'
  title-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: '1.4'
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1'
    letterSpacing: 0.02em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 40px
  xl: 64px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 48px
---

## Brand & Style

The design system is built to empower creativity through a high-energy, "brutal-modernist" aesthetic. It balances the reliability of a professional tool with the expressive freedom of a playground. The visual impact is immediate—utilizing saturated colors and massive, confident typography to guide the user.

The style is a hybrid of **High-Contrast Bold** and **Modern Corporate**. It rejects the thin, wispy lines of traditional enterprise software in favor of thick strokes, vibrant gradients, and large-scale interactive elements. The target audience includes creators, entrepreneurs, and students who require a tool that feels as dynamic as the content they are producing.

## Colors

The palette is anchored by a "Power Purple" and "Electric Cyan," creating a high-contrast relationship that feels digital-first and energetic. 

- **Primary (Power Purple):** Used for main actions and branding elements.
- **Secondary (Electric Cyan):** Used for success states, highlights, and accented UI components.
- **Tertiary (Neon Magenta):** Reserved for "New" badges, pro features, and attention-grabbing callouts.
- **Surface Strategy:** Backgrounds utilize soft, multi-stop gradients of the primary and secondary colors at low opacity, while interactive content lives on pure white surfaces to maintain legibility.

## Typography

This design system uses **Inter** exclusively to ensure a clean, neutral foundation that doesn't compete with user-generated content. 

The typographic hierarchy is aggressive. Headlines use "Extra Bold" weights with tight letter-spacing to create a "brutal" and confident feel. Body text remains functional with generous line heights to ensure the interface feels airy and approachable despite the high-saturation color palette. For mobile, headline sizes scale down significantly to preserve the "white space" luxury characteristic of the design system.

## Layout & Spacing

The layout philosophy follows a **Fluid Grid** model with a heavy emphasis on containerized content. 

- **Grid:** A 12-column grid is used for desktop, collapsing to 4 columns on mobile. 
- **Rhythm:** An 8px baseline grid governs all vertical spacing.
- **Negative Space:** The design system purposefully uses "oversized" margins (40px+) between major sections to prevent the vibrant colors from feeling cluttered or overwhelming. 
- **Alignment:** Content is generally center-aligned for marketing and landing states, but switches to a left-aligned, high-density layout for editing tools and dashboards.

## Elevation & Depth

Depth is conveyed through a combination of **Ambient Shadows** and **Tonal Layering**. 

1. **Surface Tiers:** The lowest layer is the colorful gradient background. Above this, "Floating Containers" (white surfaces) sit on the highest elevation.
2. **Shadow Character:** Shadows are extremely diffused (Blur: 30px-50px) with low opacity (8-12%). Crucially, the shadow color is not black, but a "Deep Indigo" (#1A0B2E) to keep the shadows feeling clean and integrated with the purple primary theme.
3. **Interactive Lift:** Upon hover or press, elements do not use traditional borders; instead, they increase their shadow spread or use a subtle inner glow to signify "activeness."

## Shapes

The shape language is dominated by **large, pill-shaped radii**. This "super-ellipse" approach removes all harshness from the interface, making even the most complex tools feel friendly and touch-optimized.

- **Small elements (Checkboxes):** 4px radius.
- **Medium elements (Buttons, Inputs):** 12px-16px radius (or full pill).
- **Large elements (Cards, Search Bars):** 24px-32px radius.
- **Icons:** Always contained within circular or highly rounded containers to maintain the "playful" category-button aesthetic.

## Components

### Buttons
Primary buttons use a solid Power Purple fill with white bold text. Secondary buttons use an Electric Cyan outline or a ghost style with colored text. All buttons feature a 32px height for mobile and 48px for desktop.

### Category Tiles (The "Canva" Hero)
These are the signature components. They consist of a perfectly circular background in a high-contrast color (Teal, Orange, Pink, Blue) with a simple, thick white glyph in the center. Labels sit below the icon in `label-sm`.

### Input Fields
Search bars and text inputs are pure white with a soft 1px border (#E1E4E8). They use a large 32px corner radius and include a subtle shadow to "pop" against the gradient backgrounds.

### Cards & Modals
Cards have no borders. They rely entirely on a 24px corner radius and the ambient indigo shadow for definition. Content inside cards should have a minimum internal padding of 24px.

### Badges
Small, high-contrast pills used for "NEW" or "PRO" labels. They use the Neon Magenta tertiary color with white, all-caps `label-sm` typography.