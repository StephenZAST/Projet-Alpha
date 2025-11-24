# 🖼️ Images Used - App Landing Pages

**Date:** November 20, 2025  
**Purpose:** Reference guide for all images used in app landing pages

---

## 📁 Image Directory Structure

```
frontend/website/public/images/app_mockups/
├── client app home page.png
├── client app adress screen.png
├── client app order recap screen.png
├── affiliate home page.png
├── Affiliate customer screen.png
├── affiliate login page.png
└── iMockup - Google Pixel 8 Pro.png
```

---

## 📱 Client App Page Images

### 1. Client App Home Page
- **File:** `client app home page.png`
- **Location:** Hero section + Screenshots gallery
- **Usage:**
  - Hero section phone mockup (main image)
  - Screenshots gallery (first card)
- **Dimensions:** 300x600px (recommended)
- **Format:** PNG
- **Purpose:** Showcase main app interface

### 2. Client App Address Screen
- **File:** `client app adress screen.png`
- **Location:** Screenshots gallery
- **Usage:**
  - Screenshots gallery (second card)
- **Dimensions:** 300x600px (recommended)
- **Format:** PNG
- **Purpose:** Show address management feature

### 3. Client App Order Recap Screen
- **File:** `client app order recap screen.png`
- **Location:** Screenshots gallery
- **Usage:**
  - Screenshots gallery (third card)
- **Dimensions:** 300x600px (recommended)
- **Format:** PNG
- **Purpose:** Display order confirmation screen

---

## 🤝 Affiliate App Page Images

### 1. Affiliate Home Page
- **File:** `affiliate home page.png`
- **Location:** Hero section + Screenshots gallery
- **Usage:**
  - Hero section phone mockup (main image)
  - Screenshots gallery (first card)
- **Dimensions:** 300x600px (recommended)
- **Format:** PNG
- **Purpose:** Showcase affiliate app dashboard

### 2. Affiliate Customer Screen
- **File:** `Affiliate customer screen.png`
- **Location:** Screenshots gallery
- **Usage:**
  - Screenshots gallery (second card)
- **Dimensions:** 300x600px (recommended)
- **Format:** PNG
- **Purpose:** Show customer management feature

### 3. Affiliate Login Page
- **File:** `affiliate login page.png`
- **Location:** Screenshots gallery
- **Usage:**
  - Screenshots gallery (third card)
- **Dimensions:** 300x600px (recommended)
- **Format:** PNG
- **Purpose:** Display login interface

---

## 🎨 Image Usage in Components

### Client App Page (`page.tsx`)

```typescript
// Hero section
<Image
  src="/images/app_mockups/client app home page.png"
  alt="Écran d'accueil de l'app client"
  width={300}
  height={600}
  priority
  className={styles.phoneImage}
/>

// Screenshots gallery - Image 1
<Image
  src="/images/app_mockups/client app home page.png"
  alt="Écran d'accueil"
  width={280}
  height={560}
  className={styles.screenshot}
/>

// Screenshots gallery - Image 2
<Image
  src="/images/app_mockups/client app adress screen.png"
  alt="Gestion des adresses"
  width={280}
  height={560}
  className={styles.screenshot}
/>

// Screenshots gallery - Image 3
<Image
  src="/images/app_mockups/client app order recap screen.png"
  alt="Récapitulatif de commande"
  width={280}
  height={560}
  className={styles.screenshot}
/>
```

### Affiliate App Page (`page.tsx`)

```typescript
// Hero section
<Image
  src="/images/app_mockups/affiliate home page.png"
  alt="Écran d'accueil de l'app affiliate"
  width={300}
  height={600}
  priority
  className={styles.phoneImage}
/>

// Screenshots gallery - Image 1
<Image
  src="/images/app_mockups/affiliate home page.png"
  alt="Écran d'accueil"
  width={280}
  height={560}
  className={styles.screenshot}
/>

// Screenshots gallery - Image 2
<Image
  src="/images/app_mockups/Affiliate customer screen.png"
  alt="Gestion des clients"
  width={280}
  height={560}
  className={styles.screenshot}
/>

// Screenshots gallery - Image 3
<Image
  src="/images/app_mockups/affiliate login page.png"
  alt="Connexion"
  width={280}
  height={560}
  className={styles.screenshot}
/>
```

---

## 🖼️ Image Specifications

### Recommended Dimensions
- **Hero Section:** 300x600px
- **Gallery Cards:** 280x560px
- **Aspect Ratio:** 9:18 (mobile phone)

### File Format
- **Format:** PNG (recommended)
- **Compression:** Optimized for web
- **Quality:** High quality (no artifacts)

### Optimization
- **Size:** < 500KB per image
- **Format:** PNG or WebP
- **Responsive:** Scales with CSS
- **Lazy Loading:** Applied to gallery images

---

## 📐 CSS Styling for Images

### Phone Frame Styling
```css
.phoneFrame {
  position: relative;
  width: 300px;
  height: 600px;
  background: white;
  border-radius: 40px;
  padding: 12px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
  border: 8px solid #1E293B;
  overflow: hidden;
}

.phoneFrame::before {
  content: '';
  position: absolute;
  top: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 150px;
  height: 25px;
  background: #1E293B;
  border-radius: 0 0 20px 20px;
  z-index: 10;
}

.phoneImage {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 32px;
}
```

### Screenshot Gallery Styling
```css
.screenshotItem {
  text-align: center;
}

.screenshot {
  width: 100%;
  height: auto;
  border-radius: 32px;
}
```

---

## 🔄 Image Responsive Behavior

### Desktop (1024px+)
- Hero image: 300x600px
- Gallery images: 280x560px
- Full quality displayed

### Tablet (768px - 1024px)
- Hero image: 250x500px
- Gallery images: 240x480px
- Scaled proportionally

### Mobile (< 768px)
- Hero image: 200x400px
- Gallery images: 200x400px
- Optimized for small screens

### Extra Small (< 640px)
- Hero image: 160x320px
- Gallery images: 160x320px
- Minimal size

---

## 🎯 Image Alt Text

### Client App Images
1. **Home Page:** "Écran d'accueil de l'app client"
2. **Address Screen:** "Gestion des adresses"
3. **Order Recap:** "Récapitulatif de commande"

### Affiliate App Images
1. **Home Page:** "Écran d'accueil de l'app affiliate"
2. **Customer Screen:** "Gestion des clients"
3. **Login Page:** "Connexion"

---

## 📊 Image Performance

### Optimization Tips
1. **Compression:** Use TinyPNG or similar
2. **Format:** Use PNG for quality, WebP for size
3. **Lazy Loading:** Applied to gallery images
4. **Responsive:** CSS handles scaling
5. **Caching:** Browser caching enabled

### Expected Load Times
- Hero image: < 500ms
- Gallery images: < 300ms each
- Total page: < 2.5s

---

## 🔗 Image References in Config

### In `app-pages-config.ts`
```typescript
export const APP_PAGES_SHARED = {
  images: {
    clientAppHome: '/images/app_mockups/client app home page.png',
    clientAppAddress: '/images/app_mockups/client app adress screen.png',
    clientAppRecap: '/images/app_mockups/client app order recap screen.png',
    affiliateHome: '/images/app_mockups/affiliate home page.png',
    affiliateCustomer: '/images/app_mockups/Affiliate customer screen.png',
    affiliateLogin: '/images/app_mockups/affiliate login page.png',
  },
};
```

---

## 🎨 Image Styling Features

### Phone Frame Effect
- Rounded corners (40px)
- Black border (8px)
- Notch at top (simulated)
- Shadow effect
- Padding inside frame

### Gallery Cards
- Rounded corners (32px)
- Responsive sizing
- Smooth transitions
- Hover effects

---

## 📱 Mobile Mockup Details

### Phone Frame Specifications
- **Width:** 300px (desktop), 250px (tablet), 200px (mobile)
- **Height:** 600px (desktop), 500px (tablet), 400px (mobile)
- **Border Radius:** 40px
- **Border:** 8px solid #1E293B
- **Notch Height:** 25px
- **Notch Width:** 150px

### Image Inside Frame
- **Border Radius:** 32px
- **Object Fit:** Cover
- **Width:** 100%
- **Height:** 100%

---

## 🔄 Image Update Instructions

### To Replace Images

1. **Prepare New Image**
   - Size: 300x600px (or 280x560px for gallery)
   - Format: PNG or WebP
   - Optimize for web

2. **Replace File**
   ```bash
   # Replace in public/images/app_mockups/
   cp new-image.png frontend/website/public/images/app_mockups/
   ```

3. **Update Alt Text** (if needed)
   - Edit page component
   - Update alt attribute

4. **Test**
   - View in browser
   - Check responsive design
   - Verify load time

---

## 📋 Image Checklist

- [ ] All images exist in correct directory
- [ ] Image dimensions are correct
- [ ] Images are optimized for web
- [ ] Alt text is descriptive
- [ ] Images load quickly
- [ ] Responsive design works
- [ ] Phone frame displays correctly
- [ ] Gallery images display correctly
- [ ] No broken image links
- [ ] Images look good on all devices

---

## 🚀 Image Deployment

### Before Deployment
1. [ ] Verify all images are in public folder
2. [ ] Check image paths in components
3. [ ] Verify image dimensions
4. [ ] Test on all devices
5. [ ] Check load times

### After Deployment
1. [ ] Verify images load on production
2. [ ] Check image quality
3. [ ] Monitor load times
4. [ ] Gather user feedback
5. [ ] Optimize if needed

---

## 📞 Image Support

### Common Issues

#### Images Not Loading
- Check file paths
- Verify files exist in public folder
- Check file names (case-sensitive)
- Clear browser cache

#### Images Look Blurry
- Check image dimensions
- Verify image quality
- Use higher resolution source
- Check CSS scaling

#### Images Load Slowly
- Optimize image size
- Use WebP format
- Enable compression
- Check network speed

---

## 📚 Related Documentation

- `APP_LANDING_PAGES_DOCUMENTATION.md` - Full documentation
- `INTEGRATION_GUIDE.md` - Integration instructions
- `APP_PAGES_SUMMARY.md` - Project summary
- `FILES_CREATED_SUMMARY.md` - Files created

---

**Images Reference Created:** November 20, 2025  
**Status:** ✅ Complete
