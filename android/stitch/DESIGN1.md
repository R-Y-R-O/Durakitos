---
name: Modern Professional Contact Management
colors:
  surface: '#faf8ff'
  surface-dim: '#d9d9e4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3fd'
  surface-container: '#ededf8'
  surface-container-high: '#e7e7f2'
  surface-container-highest: '#e1e2ec'
  on-surface: '#191b23'
  on-surface-variant: '#434654'
  inverse-surface: '#2e3038'
  inverse-on-surface: '#f0f0fb'
  outline: '#737685'
  outline-variant: '#c3c6d6'
  surface-tint: '#0c56d0'
  primary: '#003d9b'
  on-primary: '#ffffff'
  primary-container: '#0052cc'
  on-primary-container: '#c4d2ff'
  inverse-primary: '#b2c5ff'
  secondary: '#535f70'
  on-secondary: '#ffffff'
  secondary-container: '#d6e3f7'
  on-secondary-container: '#596576'
  tertiary: '#004e32'
  on-tertiary: '#ffffff'
  tertiary-container: '#006844'
  on-tertiary-container: '#72e9af'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2ff'
  primary-fixed-dim: '#b2c5ff'
  on-primary-fixed: '#001848'
  on-primary-fixed-variant: '#0040a2'
  secondary-fixed: '#d6e3f7'
  secondary-fixed-dim: '#bbc7db'
  on-secondary-fixed: '#101c2b'
  on-secondary-fixed-variant: '#3b4858'
  tertiary-fixed: '#82f9be'
  tertiary-fixed-dim: '#65dca4'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005235'
  background: '#faf8ff'
  on-background: '#191b23'
  surface-variant: '#e1e2ec'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '600'
    lineHeight: 32px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 40px
  xl: 64px
  container-max: 1280px
  gutter: 24px
---

## Brand & Style
The design system is centered on efficiency, reliability, and approachability. It targets professionals who require high-performance tools that feel human and uncomplicated. 

The aesthetic is **Modern Corporate Minimalism**. By blending the structured reliability of enterprise software with the breezy, open layout of a lifestyle app, the design system ensures that managing hundreds of connections never feels like a chore. Visual weight is minimized through the use of light backgrounds and purposeful white space, allowing the user's data—the contacts—to remain the focal point.

## Colors
The palette is built on a foundation of trust and growth. 
- **Primary Blue (#0052CC)**: Used for key actions, active states, and branding to evoke stability and professionalism.
- **Soft Blue (#DEEBFF)**: Utilized for subtle highlights, selected states, and secondary backgrounds to maintain a "breezy" feel without the harshness of high-contrast borders.
- **Fresh Green (#36B37E)**: Reserved for positive indicators, such as "Active" statuses, successful updates, or adding new connections.
- **Neutral Surface**: A combination of white (#FFFFFF) for interactive cards and Light Gray (#F4F5F7) for global backgrounds creates a clear sense of depth and separation without needing heavy lines.

## Typography
This design system utilizes **Inter** for its exceptional readability and neutral, modern tone. The typographic hierarchy is intentionally tight to prevent information density from feeling overwhelming. 

- **Headlines**: Use medium to semi-bold weights with slight negative letter-spacing to feel "locked-in" and authoritative.
- **Body**: Standardized at 14px and 16px to ensure high legibility in data-rich environments like contact lists and detail panels.
- **Labels**: Small, uppercase, semi-bold text is used for metadata headers (e.g., "LAST CONTACTED") to provide clear categorization at a glance.

## Layout & Spacing
The design system employs a **Fluid Grid** based on an 8px root unit to ensure mathematical harmony across all components.

- **Desktop**: A 12-column grid with 24px gutters. Content is typically housed in a centered container with a maximum width of 1280px.
- **Navigation**: A fixed side-navigation (240px-280px) is preferred for contact management, providing quick access to categories and tags.
- **Margins**: Generous 40px outer margins on desktop create the "breezy" aesthetic, while mobile devices scale down to 16px margins to maximize screen real estate.

## Elevation & Depth
Depth is conveyed through **Ambient Shadows** and **Tonal Layering** rather than heavy borders.

- **Level 0 (Background)**: The Light Gray (#F4F5F7) base layer.
- **Level 1 (Cards/Surface)**: Pure white (#FFFFFF) surfaces with a very subtle shadow (0px 2px 4px rgba(0, 0, 0, 0.05)). This is used for contact list items and main content areas.
- **Level 2 (Overlays/Dropdowns)**: Elevated surfaces like modals or context menus use a more pronounced, diffused shadow (0px 10px 20px rgba(0, 0, 0, 0.08)) to indicate interactivity and focus.
- **Interactions**: On hover, cards may lift slightly (Level 2) or gain a subtle Primary Blue outline to confirm the user's target.

## Shapes
The shape language is consistently soft and approachable. 
- **Standard Components**: Buttons, input fields, and small cards use a **8px radius**.
- **Container Elements**: Larger modules, profile headers, and main content cards use a **12px to 16px radius** to reinforce the modern, friendly mood.
- **Icons**: Iconography should be "Linear" or "Bold" with rounded caps and joins to match the corner radius of the UI components.

## Components
- **Buttons**: Primary CTA buttons use a solid #0052CC fill with white text. Secondary buttons use the #DEEBFF fill with #0052CC text. All buttons feature 8px rounded corners and a height of 40px for comfortable clicking.
- **Contact Cards**: A white surface with 12px rounded corners. Contains an avatar (circular), primary name (Headline-sm), and secondary details (Body-md).
- **Input Fields**: Minimalist style with a 1px border (#DFE1E6) that transitions to Primary Blue on focus. Labels sit above the field in Label-md style.
- **Chips/Tags**: Small capsules used for contact categories (e.g., "Colleague", "Client"). These use a 16px (pill) radius, a light background color, and dark text for high contrast and quick scanning.
- **Search Bar**: A prominent, full-width element with an "Intuitive Iconography" search lens. It should appear elevated or with a subtle Soft Blue border to signify its importance as a primary navigation tool.
- **Lists**: Contact lists should have generous vertical padding (16px per row) to ensure the interface feels airy and readable.