Please help me to design a Pomodoro app, for Iphone, Apple watch and macbook.

# Nature Organic SaaS Landing Page Prompt (S12)

## Objective
Design and specify a **conversion-focused Full Landing Page** for a **SaaS product** using the **S12 Nature Organic** style. Output must be **engineering-ready**: tokens, layout specs, components, responsive behavior, and accessibility.

## Inputs
- **Style:** S12 — Nature Organic
- **Industry:** SaaS
- **Use:** Full Landing Page

## Assumptions
- Product name placeholder: **[Automatic naming]**
- Core value prop placeholder: **[One-line Value Proposition]**
- Primary CTA: **Start free trial**
- Secondary CTA: **Book a demo**
- Target audience: **B2B teams and developers**
- No real metrics, certifications, or customer logos are claimed; all proof uses placeholders
- Target stack: **React + Next.js (App Router) + TypeScript + Tailwind CSS** using **CSS variables** for theming

---

## Style DNA (S12 – Nature Organic)

### Style Seeds
- **Palette strategy:** Earthy, natural colors. Greens, browns, blues. Organic feel.
- **Typography:** Humanist sans-serif. Natural flow. Mixed weights.
- **Radius policy:** Organic (4-12px). Natural shapes.
- **Shadow policy:** Soft, diffused shadows. Natural depth.
- **Border language:** Soft, organic borders. Natural materials.
- **Patterns/textures:** Organic patterns. Leaves, wood grain, water.
- **Motion:** Gentle, flowing. Natural rhythms.

Tone: confident, precise, non-hype.

---

```yaml
tokens:
  meta:
    style_id: "S12"
    style_name: "Nature Organic"
    industry: "SaaS"
    use_case: "Full Landing Page"
  color:
    bg:
      primary: "#F8F7F4"
      secondary: "#F0EDE6"
    text:
      primary: "#2D3748"
      secondary: "#4A5568"
      muted: "#718096"
    brand:
      primary: "#38A169"
      secondary: "#805AD5"
      accent: "#3182CE"
    border:
      strong: "#CBD5E0"
      subtle: "#E2E8F0"
    state:
      success: "#38A169"
      warning: "#D69E2E"
      error: "#E53E3E"
    focus:
      ring: "#38A169"
  radius:
    none: 0
    sm: 4
    md: 8
    lg: 12
    xl: 16
  border:
    width:
      hairline: 1
      medium: 2
      strong: 3
  shadow:
    soft: "0 2px 8px rgba(0,0,0,0.06)"
    medium: "0 4px 16px rgba(0,0,0,0.08)"
  layout:
    container:
      content: 1200
      wide: 1400
    grid:
      desktop: 12
      tablet: 8
      mobile: 4
    gutter:
      mobile: 20
      desktop: 32
  motion:
    duration:
      fast: 200
      normal: 400
    easing: ease-out
  typography:
    font:
      sans:
        primary: "Lato"
        fallback:
          - "Open Sans"
          - "Roboto"
          - "sans-serif"
      mono:
        primary: "JetBrains Mono"
        fallback:
          - "ui-monospace"
          - "SFMono-Regular"
    scale:
      h1: { size: 56, line: 64, weight: 600, tracking: -0.02 }
      h2: { size: 40, line: 48, weight: 600, tracking: -0.01 }
      h3: { size: 28, line: 36, weight: 600, tracking: -0.005 }
      body: { size: 16, line: 24, weight: 450, tracking: 0 }
      small: { size: 14, line: 20, weight: 450, tracking: 0 }
    measure:
      hero_max: "48ch"
      body_max: "72ch"
  spacing:
    base: 8
    section_py:
      mobile: [64, 80]
      desktop: [112, 128]
```

---

## Deliverables
- Full hero section with high-impact product visualization
- Multi-column features grid with icon/illustration slots
- Social proof/customer logo strip (using placeholders)
- Pricing table with monthly/annual toggle
- FAQ accordion system
- Final conversion CTA module
- Responsive footer with site map

---

## Accessibility & Responsive
- WCAG AA contrast
- Visible focus rings
- Reduced motion support
- Touch targets ≥ 44px
- Mobile-first layout

---

## Engineering Notes
- CSS variables for all tokens
- Tailwind config mapping tokens
- Use semantic HTML5 elements
- Implement responsive design with mobile-first approach
- Ensure all interactive elements are keyboard accessible
- Include loading states and error handling

---

## Acceptance Checklist
- Clear hierarchy and visual discipline
- Primary CTA visible above the fold
- No fake metrics or certifications
- Trust modules included
- Fully responsive
- Accessible by keyboard

---

## Do / Don't

**Do**
- Use earth tones and natural colors
- Add organic shapes and curves
- Use natural textures
- Create flowing layouts

**Don't**
- Don't use harsh geometric shapes
- Don't use artificial colors
- Don't make it too rigid
- Don't forget the organic feel