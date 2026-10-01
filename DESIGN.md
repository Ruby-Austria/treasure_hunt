# Design System — TreasureHunt.io

## 1. Visual Theme & Atmosphere

TreasureHunt.io is a location-based adventure platform that blends the discovery warmth of a travel app with the playful energy of a game. The design operates on a clean, airy canvas of soft blue-to-white gradients (`blue-50` to `white`) that evoke open sky and exploration, anchored by a confident primary blue (`#2563eb` / `blue-600`) that signals trust and action.

The typography uses the system font stack — clean, fast-loading, and universally readable across devices used outdoors in varying light conditions. Font weights lean toward semibold (600) and bold (700) for headings, creating confident hierarchy without heaviness. The overall feel is approachable-professional: friendly enough for casual players, polished enough for a commercial platform.

What distinguishes TreasureHunt.io is its multi-color stat system — blue for hunts, green for clues, purple for locations, orange for cities — creating a vibrant dashboard that feels alive with data. Cards use generous rounded corners (`rounded-2xl`) and layered shadows (`shadow-xl`) for a tactile, card-game-like elevation. The interface should feel like a well-designed board game box: inviting, colorful, and promising adventure.

**Key Characteristics:**
- Soft gradient canvas: `bg-gradient-to-b from-blue-50 to-white` as default page background
- Primary blue (`blue-600` / `#2563eb`) for CTAs and brand moments
- Multi-color semantic system: blue (hunts), green (clues), purple (locations), orange (cities)
- System font stack — optimized for outdoor/mobile readability
- Generous rounding: `rounded-lg` buttons, `rounded-2xl` cards, `rounded-full` icons
- Warm near-black text (`gray-900`) — never pure `#000000`
- White card surfaces with `shadow-xl` elevation
- Game-inspired visual language: progress bars, badges, stat counters

## 2. Color Palette & Roles

### Primary Brand
- **Adventure Blue** (`blue-600` / `#2563eb`): Primary CTA buttons, active links, brand accent
- **Deep Blue** (`blue-700` / `#1d4ed8`): Hover state for primary buttons
- **Sky Background** (`blue-50` / `#eff6ff`): Page background tint, subtle section backgrounds
- **Light Blue** (`blue-100` / `#dbeafe`): Icon circles, secondary backgrounds

### Semantic Game Colors
- **Hunt Blue** (`blue-600` / `#2563eb`): Hunt count, hunt-related elements
- **Clue Green** (`green-600` / `#16a34a`): Clue count, success states, completion
- **Location Purple** (`purple-600` / `#9333ea`): Location count, discovery elements
- **City Orange** (`orange-600` / `#ea580c`): City count, exploration elements

### Text Scale
- **Primary Text** (`gray-900` / `#111827`): Headings, important content — warm near-black
- **Secondary Text** (`gray-700` / `#374151`): Subheadings, emphasized body
- **Body Text** (`gray-600` / `#4b5563`): Standard body text, descriptions
- **Muted Text** (`gray-500` / `#6b7280`): Labels, metadata, helper text
- **White Text** (`white` / `#ffffff`): Text on dark/colored backgrounds

### Surface & Depth
- **Card Surface** (`white`): Cards, modals, elevated containers
- **Section Background** (`gray-50` / `#f9fafb`): Alternating section backgrounds
- **Page Background**: `bg-gradient-to-b from-blue-50 to-white`
- **Dark Surface** (`blue-600`): Footer CTA, hero overlays

### Status & Feedback
- **Success**: `green-600` text, `green-50` background, `green-200` border
- **Error**: `red-600` text, `red-50` background, `red-200` border
- **Warning**: `yellow-600` text, `yellow-50` background, `yellow-200` border
- **Info**: `blue-600` text, `blue-50` background, `blue-200` border

### Admin Interface
- **Admin Sidebar** (`#2c3e50`): Dark blue-gray sidebar background
- **Admin Text** (`#ecf0f1`): Light text on dark sidebar
- **Admin Content BG** (`gray-100`): Light admin content area

## 3. Typography Rules

### Font Family
- **Primary**: System stack — `ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif`
- **Monospace** (code/debug): `ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', monospace`

### Hierarchy

| Role | Tailwind Class | Size | Weight | Use |
|------|---------------|------|--------|-----|
| Hero Display | `text-5xl sm:text-6xl font-bold` | 3rem / 3.75rem | 700 | Landing page hero heading |
| Page Heading | `text-3xl font-bold` | 1.875rem | 700 | Page titles, section headers |
| Section Heading | `text-2xl font-semibold` | 1.5rem | 600 | Card group titles, subsections |
| Card Title | `text-xl font-semibold` | 1.25rem | 600 | Individual card headings |
| Large Body | `text-lg` | 1.125rem | 400 | Hero descriptions, lead text |
| Body | `text-base` | 1rem | 400 | Standard body text |
| Small Body | `text-sm font-medium` | 0.875rem | 500 | Labels, metadata, badges |
| Stat Number | `text-4xl font-bold` | 2.25rem | 700 | Dashboard stat counters |
| Micro Label | `text-sm font-medium uppercase tracking-wide` | 0.875rem | 500 | Stat labels, category labels |

### Principles
- **Weight discipline**: Body at 400, labels/meta at 500 (medium), subheadings at 600 (semibold), headings at 700 (bold). No thin weights — outdoor readability matters.
- **Color as hierarchy**: Use `gray-900` for primary headings, `gray-600` for body, `gray-500` for meta — three clear levels.
- **Semantic color in stats**: Stat numbers use their semantic color (`text-blue-600`, `text-green-600`, etc.) — the only place where colored text appears in body content.
- **Uppercase for labels only**: `uppercase tracking-wide` reserved for stat labels and category markers.

## 4. Component Stylings

### Buttons

**Primary (CTA)**
```
class="inline-flex items-center justify-center px-8 py-4 text-lg font-semibold
       text-white bg-blue-600 rounded-lg hover:bg-blue-700
       transition-colors shadow-lg hover:shadow-xl
       transform hover:-translate-y-0.5 transition-transform"
```
- Use for: Main actions (Start Playing, Sign Up, Create Hunt)
- Always includes subtle lift on hover (`-translate-y-0.5`)

**Secondary (Outlined)**
```
class="inline-flex items-center justify-center px-8 py-4 text-lg font-semibold
       text-blue-600 bg-white border-2 border-blue-600 rounded-lg
       hover:bg-blue-50 transition-colors"
```
- Use for: Alternative actions (Browse Hunts, View Details)

**Danger**
```
class="px-4 py-2 text-sm font-medium text-white bg-red-600 rounded-lg
       hover:bg-red-700 transition-colors"
```
- Use for: Destructive actions (Delete, Logout)

**Small/Inline**
```
class="px-4 py-2 text-sm font-medium text-blue-600 hover:text-blue-700
       font-semibold transition-colors"
```
- Use for: Inline links that look like buttons (Browse All Hunts)

### Cards

**Elevated Card (Stats, Featured)**
```
class="bg-white rounded-2xl shadow-xl p-8"
```
- Use for: Stats dashboard, featured content, important information blocks

**Standard Card (Hunt listing, Content)**
```
class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow
       border border-gray-100"
```
- Use for: Hunt cards, content listings, form containers

**Subtle Card (Placeholder, Empty state)**
```
class="bg-gray-50 rounded-lg py-12 text-center"
```
- Use for: Empty states, placeholder content, loading states

### Inputs & Forms

**Text Input**
```
class="w-full px-4 py-3 border border-gray-300 rounded-lg
       focus:ring-2 focus:ring-blue-500 focus:border-blue-500
       transition-colors"
```

**Label**
```
class="block text-sm font-semibold text-gray-700 mb-2"
```

**Form Container**
```
class="max-w-md mx-auto bg-white rounded-lg shadow-md p-8"
```

### Navigation

**Logged-in Nav Bar**
```
class="bg-white border-b border-gray-200 shadow-sm"
```
- Logo: `text-xl font-bold text-gray-900`
- Nav links: `text-gray-600 hover:text-gray-900 px-4 py-2 rounded-lg hover:bg-gray-50`
- Active link: `text-blue-600 font-semibold`

### Alerts

**Success Alert**
```
class="p-4 bg-green-50 text-green-800 border border-green-200 rounded-lg"
```

**Error Alert**
```
class="p-4 bg-red-50 text-red-800 border border-red-200 rounded-lg"
```

### Stat Counter Block
```html
<div class="text-center">
  <div class="text-4xl font-bold text-blue-600 mb-2">42</div>
  <div class="text-sm font-medium text-gray-500 uppercase tracking-wide">Hunts</div>
</div>
```
- Each stat uses its semantic color: blue/green/purple/orange

### Icon Circles
```
class="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4"
```
- Icon SVGs inside: `class="w-8 h-8 text-blue-600"` with `fill="none" stroke="currentColor"`
- Color matches semantic system (blue-100/blue-600, green-100/green-600, purple-100/purple-600)

## 5. Layout Principles

### Spacing System
- Base unit: Tailwind's 4px (`spacing * 1`)
- Standard scale: `1 (4px)`, `2 (8px)`, `4 (16px)`, `6 (24px)`, `8 (32px)`, `12 (48px)`, `16 (64px)`
- Section vertical padding: `py-16` (64px) — generous breathing room between sections
- Card internal padding: `p-6` (24px) standard, `p-8` (32px) elevated
- Component gaps: `gap-4` (16px) standard, `gap-6` (24px) cards, `gap-8` (32px) sections

### Grid & Container
- **Max content width**: `max-w-6xl mx-auto` (72rem / 1152px) — main content
- **Narrow content**: `max-w-4xl mx-auto` (56rem) — CTA sections, text-heavy areas
- **Form width**: `max-w-md mx-auto` (28rem / 448px) — login, signup forms
- **Horizontal padding**: `px-4 sm:px-6 lg:px-8` — responsive edge padding
- **Card grid**: `grid md:grid-cols-3 gap-8` — 3 columns on desktop, stacked on mobile
- **Stat grid**: `grid grid-cols-2 md:grid-cols-4 gap-6` — 4 columns desktop, 2 mobile

### Whitespace Philosophy
- **Adventure-paced scrolling**: `py-16` (64px) between major sections creates a leisurely scroll pace — exploring hunts should feel unhurried, like browsing a map.
- **Card breathing room**: `gap-8` (32px) between cards gives each hunt its own space — no crowding.
- **Section contrast**: Alternate between `bg-white` and gradient/tinted backgrounds to create visual rhythm.

### Border Radius Scale
- **Subtle** (`rounded`): 4px — small badges, tags
- **Standard** (`rounded-lg`): 8px — buttons, inputs, standard cards, alerts
- **Elevated** (`rounded-2xl`): 16px — featured cards, stat blocks, modals
- **Circle** (`rounded-full`): 50% — icon circles, avatars, circular buttons

## 6. Depth & Elevation

| Level | Tailwind Class | CSS Value | Use |
|-------|---------------|-----------|-----|
| Flat (0) | — | No shadow | Page background, inline content |
| Subtle (1) | `shadow-sm` | `0 1px 2px rgba(0,0,0,0.05)` | Nav bar, subtle dividers |
| Standard (2) | `shadow-md` | `0 4px 6px rgba(0,0,0,0.07), 0 2px 4px rgba(0,0,0,0.06)` | Standard cards, dropdowns |
| Elevated (3) | `shadow-lg` | `0 10px 15px rgba(0,0,0,0.1), 0 4px 6px rgba(0,0,0,0.05)` | Hover states, buttons |
| Hero (4) | `shadow-xl` | `0 20px 25px rgba(0,0,0,0.1), 0 8px 10px rgba(0,0,0,0.04)` | Featured cards, stat blocks, CTAs |

**Shadow Philosophy**: Shadows increase on interaction (hover, focus). Cards start at `shadow-md` and lift to `shadow-lg` on hover. CTA buttons start at `shadow-lg` and lift to `shadow-xl`. This progressive elevation creates a tactile, game-piece-like feel — elements respond to attention.

## 7. Do's and Don'ts

### Do
- Use `gray-900` for text — never pure `#000000`
- Apply `blue-600` only for primary CTAs and brand moments — it's the hero accent
- Use semantic colors consistently: blue=hunts, green=clues, purple=locations, orange=cities
- Apply `rounded-lg` for standard elements, `rounded-2xl` for featured/elevated elements
- Use `py-16` between major page sections — the adventure pace matters
- Use `shadow-md` → `shadow-lg` hover transitions on cards — tactile feedback
- Keep forms at `max-w-md` centered — focused, not overwhelming
- Use system font stack — fast loading and outdoor-readable
- Apply `transition-colors` or `transition-shadow` on all interactive elements
- Use `bg-gradient-to-b from-blue-50 to-white` for landing/public pages

### Don't
- Don't use pure black (`#000000`) for text — always `gray-900`
- Don't apply semantic game colors (green, purple, orange) outside their domain
- Don't use `shadow-2xl` or larger — the max elevation is `shadow-xl`
- Don't mix inline styles with Tailwind classes — use Tailwind exclusively for new code
- Don't use custom hex colors when a Tailwind color exists (e.g. use `blue-600` not `#3498db`)
- Don't add more than one primary CTA per viewport — guide the user clearly
- Don't use thin font weights (300) — minimum is 400 for body, 600 for emphasis
- Don't skip hover/focus states on interactive elements — every clickable needs feedback
- Don't use sharp corners (`rounded-none`) — minimum is `rounded` (4px)
- Don't create new color roles without updating this document

## 8. Responsive Behavior

### Breakpoints

| Name | Tailwind Prefix | Width | Key Changes |
|------|----------------|-------|-------------|
| Mobile | (default) | < 640px | Single column, stacked layout, `text-5xl` hero |
| Tablet | `sm:` | >= 640px | 2-column stats, `sm:flex-row` buttons, `sm:text-6xl` hero |
| Desktop | `md:` | >= 768px | 3-column cards, `md:grid-cols-3` steps, `md:grid-cols-4` stats |
| Large Desktop | `lg:` | >= 1024px | Full horizontal padding `lg:px-8` |

### Touch Targets
- Minimum button size: `px-4 py-2` (32px height minimum)
- CTA buttons: `px-8 py-4` (generous touch target for outdoor/mobile use)
- Nav links: `px-4 py-2` with hover background for clear target area
- Card tap: entire card clickable on mobile (wrap in link or add click handler)

### Collapsing Strategy
- **Stat grid**: 4 columns → 2 columns on mobile (`grid-cols-2 md:grid-cols-4`)
- **Step cards**: 3 columns → stacked on mobile (`md:grid-cols-3`)
- **CTA buttons**: row → column on mobile (`flex-col sm:flex-row`)
- **Hero text**: `text-5xl` → `sm:text-6xl` (slightly larger on tablet+)
- **Navigation**: horizontal → hamburger menu on mobile (not yet implemented)
- **Horizontal padding**: `px-4` → `sm:px-6` → `lg:px-8` (progressive padding)

### Outdoor/Mobile Considerations
- High contrast text (`gray-900` on white) for sunlight readability
- Large touch targets for gloved/moving hands
- System fonts for fastest loading on cellular connections
- Minimal decorative elements that don't aid navigation

## 9. Agent Prompt Guide

### Quick Color Reference
- Page background: `bg-gradient-to-b from-blue-50 to-white`
- Card surface: `bg-white`
- Primary text: `text-gray-900`
- Body text: `text-gray-600`
- Meta/label text: `text-gray-500`
- Primary accent: `text-blue-600` / `bg-blue-600`
- Success/clue: `text-green-600`
- Location: `text-purple-600`
- City/explore: `text-orange-600`
- Error: `text-red-600`

### Example Component Prompts
- "Create a hunt card: `bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow border border-gray-100`. Title at `text-xl font-semibold text-gray-900`. Description at `text-gray-600`. Difficulty badge: `text-sm font-medium px-3 py-1 rounded bg-blue-50 text-blue-600`. Location count at bottom: `text-sm text-gray-500`."
- "Design a stat counter block: `bg-white rounded-2xl shadow-xl p-8`. Grid `grid-cols-2 md:grid-cols-4 gap-6`. Each stat: number at `text-4xl font-bold` in semantic color, label at `text-sm font-medium text-gray-500 uppercase tracking-wide`."
- "Build a page section: `py-16` padding. Container: `max-w-6xl mx-auto px-4 sm:px-6 lg:px-8`. Heading: `text-3xl font-bold text-center text-gray-900 mb-12`."
- "Create a CTA banner: `bg-blue-600 text-white py-16`. Container: `max-w-4xl mx-auto px-4 text-center`. Heading: `text-3xl font-bold mb-4`. Description: `text-xl text-blue-100 mb-8`. Button: `bg-white text-blue-600 rounded-lg px-8 py-4 font-semibold hover:bg-gray-100`."
- "Design a form page: `max-w-md mx-auto mt-16`. Card: `bg-white rounded-lg shadow-md p-8`. Heading: `text-2xl font-semibold text-center text-gray-900 mb-8`. Input: `w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500`. Submit: full-width primary button."

### Iteration Guide
1. Start with `bg-gradient-to-b from-blue-50 to-white` background on public pages
2. Use `max-w-6xl mx-auto px-4 sm:px-6 lg:px-8` for content containers
3. `py-16` between major sections — the adventure-paced scroll
4. Cards: `bg-white rounded-lg shadow-md` standard, `rounded-2xl shadow-xl` for featured
5. Primary blue (`blue-600`) for CTAs only — one per viewport
6. Semantic colors for stats only: blue=hunts, green=clues, purple=locations, orange=cities
7. Always add hover transitions: `hover:shadow-lg transition-shadow` on cards
8. Text hierarchy: `gray-900` headings, `gray-600` body, `gray-500` meta
9. Responsive: mobile-first, test at 375px, 768px, 1024px widths
