# GitHub Actions CI/CD

This project includes automated workflows for building, testing, and deploying your Flutter application.

## Workflows

### 1. Build and Deploy (`deploy.yml`)
Automatically builds and pushes Docker images to GitHub Container Registry (GHCR).

**Triggers:**
- Push to `main` branch
- Pull requests to `main` branch

**What it does:**
- Builds Docker image using multi-stage build
- Pushes to `ghcr.io` (GitHub Container Registry)
- Tags with branch, commit SHA, and `latest`
- Uses Docker layer caching for faster builds

**Image location:**
```
ghcr.io/MeghVyas3132/Society-CRM:latest
```

**Pull and run locally:**
```bash
docker pull ghcr.io/MeghVyas3132/Society-CRM:latest
docker run -p 8080:80 ghcr.io/MeghVyas3132/Society-CRM:latest
```

### 2. Flutter Tests (`test.yml`)
Runs Flutter unit and widget tests on every push and PR.

**Triggers:**
- Push to `main` branch
- Pull requests to `main` branch

**What it does:**
- Sets up Flutter 3.10.0
- Gets dependencies with `flutter pub get`
- Runs tests with coverage
- Uploads coverage to Codecov

### 3. Firebase Hosting Deploy (`firebase-deploy.yml`)
Deploys the Flutter web app to Firebase Hosting.

**Triggers:**
- After successful Build and Deploy workflow completion

**What it does:**
- Builds Flutter web app
- Deploys to Firebase Hosting
- Uses project ID: `society-crm-672aa`

**Requires:**
- `FIREBASE_SERVICE_ACCOUNT` secret (Firebase service account JSON)

## Setting Up Secrets

### For Docker Push (GHCR)
No additional setup needed. GitHub Actions automatically uses `GITHUB_TOKEN`.

### For Firebase Hosting Deploy
1. Generate a Firebase service account:
   ```bash
   firebase init
   firebase login
   firebase deploy --only hosting
   ```

2. Export service account as JSON and add to GitHub Secrets:
   - Go to repo Settings → Secrets and variables → Actions
   - Add `FIREBASE_SERVICE_ACCOUNT` with service account JSON content

## Manual Commands

### Build Docker Image Locally
```bash
docker build -t society-crm:latest .
docker run -p 8080:80 society-crm:latest
```

### Deploy to Firebase Hosting Manually
```bash
flutter build web --release
firebase deploy --only hosting --project society-crm-672aa
```

## Using Published Docker Images

Pull and run any tagged version:

```bash
# Latest
docker pull ghcr.io/MeghVyas3132/Society-CRM:latest
docker run -p 8080:80 ghcr.io/MeghVyas3132/Society-CRM:latest

# Specific branch
docker pull ghcr.io/MeghVyas3132/Society-CRM:main-abc123def

# Specific tag (semver)
docker pull ghcr.io/MeghVyas3132/Society-CRM:1.0.0
```

## View Workflow Results

1. Go to your repository: https://github.com/MeghVyas3132/Society-CRM
2. Click "Actions" tab
3. Select workflow to view:
   - Build and Deploy
   - Flutter Tests
   - Deploy to Firebase Hosting

## Troubleshooting

### Build Fails
- Check Docker file for errors
- Review workflow logs in Actions tab
- Ensure all dependencies in pubspec.yaml are correct

### Tests Fail
- Review test output in workflow logs
- Run `flutter test` locally to debug
- Check coverage report

### Firebase Deploy Fails
- Verify `FIREBASE_SERVICE_ACCOUNT` secret is set
- Check Firebase project ID is correct
- Ensure Firebase Hosting is enabled in your project

## Next Steps

1. Configure `FIREBASE_SERVICE_ACCOUNT` secret for Firebase deployment
2. Push a commit to trigger workflows
3. Monitor Actions tab for build results
4. Pull Docker image once build succeeds
