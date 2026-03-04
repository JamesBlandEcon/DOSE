## Google Sheets Setup

### 1. Create a Google Cloud project and enable APIs
1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Create a new project
3. Go to **APIs & Services** → **Library**
4. Search for and enable **Google Sheets API**
5. Search for and enable **Google Drive API**

### 2. Create a service account and download the key
1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **Service Account**
3. Give it a name and click through the steps
4. Once created, click on the service account → **Keys** tab → **Add Key** → **Create new key** → **JSON**
5. The JSON file downloads automatically — put it in your app folder and update the filename in `app.R`:
```r
gs4_auth(path = "your-key-file.json")
```

### 3. Create the Google Sheet
1. Go to [sheets.google.com](https://sheets.google.com) and create a new sheet
2. Share it with the service account email (looks like `name@project.iam.gserviceaccount.com`) with **Editor** access
3. Copy the sheet ID from the URL: `https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID_HERE/edit`
4. Update the sheet ID in `app.R`:
```r
sheet_append(
  ss   = as_id("YOUR_SHEET_ID_HERE"),
  data = data() |> mutate(id = id())
)
```

### 4. Deploy to shinyapps.io
Make sure the JSON key file is in your app folder when you deploy:
```r
rsconnect::deployApp()
```
The key file will be deployed automatically alongside your app.

### 5. Pass a participant ID via the URL
Append `?id=YOUR_ID` to the app URL to tag responses with a participant ID:
```
https://yourapp.shinyapps.io/yourapp/?id=participant123
```
If no ID is provided, the app will record the time instead.
