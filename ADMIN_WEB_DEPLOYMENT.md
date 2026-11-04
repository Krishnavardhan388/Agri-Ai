# AGRI AI — Administrator Web Dashboard Deployment & Hosting Guide 🌾🖥️

This guide explains how to build, test, and deploy the **AGRI AI Administrator Web Operations Hub** to production hosting platforms (Firebase Hosting, GitHub Pages, or Docker/Cloud Run).

---

## 📌 1. Overview of the Admin Web Dashboard

The AGRI AI Operations Dashboard provides a responsive desktop and tablet control center for platform administrators with 6 dedicated modules:

| Section | Key Operational Capabilities |
| :--- | :--- |
| **1. Executive Overview & KPIs** | Real-time GMV, order volume, active farmer count, weekly revenue charts, and Gemini pathology breakdown. |
| **2. Farmer & Fleet KYC Hub** | Land passbook and driving license verification, document zoom inspection, and 1-click approvals/rejections. |
| **3. Marketplace Moderation** | Anti-price-gouging automated anomaly alerts, organic certification verification, and instant item unlisting. |
| **4. Live Logistics & Dispatch** | Real-time transit monitoring, driver reassignment, and admin doorstep OTP override capability. |
| **5. APMC Mandi Rates & Outbreaks** | Government market price sync, localized price overrides, and district-wide SMS pest alert broadcasts. |
| **6. System Configurations** | Gemini Vision model switching (Flash vs. Pro), Razorpay payment mode toggle, platform commission %, and rural TTS speech rate. |

---

## 🚀 2. Building the Web Release Package

To compile the Flutter web application into production-optimized HTML, CSS, JavaScript, and WebAssembly bundles:

```powershell
# Set Java environment and compile web release
$env:JAVA_HOME = 'D:\android studio\jbr'
& 'C:\src\flutter\flutter_windows_3.47.9-stable\flutter\bin\flutter.bat' build web --release
```

The output bundle is generated inside the directory:
```text
build/
└── web/
    ├── index.html              # HTML5 single-page application entry point
    ├── main.dart.js            # Tree-shaken compiled Dart web binary
    ├── flutter.js              # Flutter web bootstrapper
    ├── assets/                 # Poppins fonts, SVG icons, and mock assets
    ├── canvaskit/              # High-performance CanvasKit renderer engine
    └── manifest.json           # Progressive Web App (PWA) manifest
```

---

## 💻 3. Running Locally for Live Testing

### Method A: Direct Chrome Debugging (Recommended for Development)
```powershell
& 'C:\src\flutter\flutter_windows_3.47.9-stable\flutter\bin\flutter.bat' run -d chrome
```

### Method B: Testing Compiled Production Web Assets Locally
You can verify the production `build/web` folder using Python or Node.js before deploying:

```powershell
# Using Python built-in HTTP server:
cd "d:\antigravity\ai crop disease detection system\build\web"
python -m http.server 8080

# Or using npx serve:
npx serve "d:\antigravity\ai crop disease detection system\build\web" -p 8080
```
Open [http://localhost:8080](http://localhost:8080) in your browser.

---

## ☁️ 4. Deployment Option 1: Firebase Hosting (Recommended)

Firebase Hosting provides global CDN caching, free automated SSL certificates, and zero-latency integration with your existing Cloud Firestore and Firebase Auth project.

### Step-by-Step Instructions:

1. **Install the Firebase CLI** (if not already installed):
   ```powershell
   npm install -g firebase-tools
   ```

2. **Authenticate with Google / Firebase**:
   ```powershell
   firebase login
   ```

3. **Initialize Firebase Hosting in the Project Root**:
   ```powershell
   cd "d:\antigravity\ai crop disease detection system"
   firebase init hosting
   ```
   During the interactive prompt:
   - **Select Project**: Choose your existing AGRI AI Firebase project.
   - **Public Directory**: Enter `build/web`
   - **Configure as single-page app (rewrite all urls to /index.html)**: Enter `Yes` (`Y`)
   - **Set up automatic builds and deploys with GitHub?**: Enter `No` (`N`)
   - **File build/web/index.html already exists. Overwrite?**: Enter `No` (`N`)

4. **Verify your `firebase.json` configuration**:
   Ensure `firebase.json` includes SPA rewrites:
   ```json
   {
     "hosting": {
       "public": "build/web",
       "ignore": [
         "firebase.json",
         "**/.*",
         "**/node_modules/**"
       ],
       "rewrites": [
         {
           "source": "**",
           "destination": "/index.html"
         }
       ],
       "headers": [
         {
           "source": "**/*.@(js|css|wasm)",
           "headers": [
             {
               "key": "Cache-Control",
               "value": "max-age=31536000"
             }
           ]
         }
       ]
     }
   }
   ```

5. **Deploy to Production**:
   ```powershell
   firebase deploy --only hosting
   ```
   Firebase will upload the assets and provide your live production URL:
   `https://<your-project-id>.web.app` or `https://<your-project-id>.firebaseapp.com`.

---

## 🐙 5. Deployment Option 2: GitHub Pages (Free Hosting)

GitHub Pages allows you to host the web admin panel directly from your GitHub repository for free.

1. **Build with base-href matching your repository name**:
   ```powershell
   flutter build web --release --base-href "/ai-crop-disease-detection-system/"
   ```

2. **Deploy using `peanut` or Git branch**:
   ```powershell
   # Commit and push build/web to the gh-pages branch:
   cd build/web
   git init
   git checkout -b gh-pages
   git add -A
   git commit -m "Deploy AGRI AI Admin Web Dashboard"
   git remote add origin https://github.com/<your-username>/<your-repo-name>.git
   git push -f origin gh-pages
   ```

3. In GitHub Repository **Settings** → **Pages**:
   - Source: Deploy from branch `gh-pages` / `/ (root)`.
   - Your dashboard will be live at `https://<your-username>.github.io/<your-repo-name>/`.

---

## 🐳 6. Deployment Option 3: Docker & Cloud Run (Enterprise NGINX)

For enterprise self-hosted environments or Google Cloud Run:

Create a `Dockerfile` in the project root:
```dockerfile
# Stage 1: Serve with high-performance NGINX Alpine
FROM nginx:1.25-alpine

# Copy Flutter build output
COPY build/web /usr/share/nginx/html

# Custom NGINX SPA configuration
RUN echo 'server { \
    listen 8080; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
```

Build and run container:
```powershell
docker build -t agri-ai-admin:latest .
docker run -p 8080:8080 agri-ai-admin:latest
```

---

## 🔒 7. Security & Environment Configuration

1. **Restricting Admin Route Access**:
   Ensure Firestore Security Rules allow document write access to users with `role == 'admin'` custom claims:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /mandi_rates/{document} {
         allow read: if true;
         allow write: if request.auth != null && request.auth.token.role == 'admin';
       }
       match /kyc_applications/{document} {
         allow read, write: if request.auth != null && request.auth.token.role == 'admin';
       }
     }
   }
   ```

2. **CORS (Cross-Origin Resource Sharing)**:
   If hosting web on a custom domain, configure Google Cloud Storage CORS to allow image uploads from your web domain:
   ```json
   [
     {
       "origin": ["https://admin.agriai.in", "http://localhost:8080"],
       "method": ["GET", "POST", "PUT", "DELETE"],
       "responseHeader": ["Content-Type", "Authorization"],
       "maxAgeSeconds": 3600
     }
   ]
   ```

---

## 🔄 8. Role Switching: Web Dashboard to Mobile Experience

The AGRI AI application supports all user roles simultaneously:
- When launched on desktop or tablet viewports, administrators have full access to the **6 Operations Tabs**.
- Administrators can click the **"Switch Role"** button in the top bar to preview the application as a **Farmer**, **Customer (Buyer)**, or **Delivery Partner** in real time.
- All 52 automated tests in `test/admin_test.dart` and `test/widget_test.dart` ensure pixel-perfect rendering across both mobile and desktop screen sizes.
