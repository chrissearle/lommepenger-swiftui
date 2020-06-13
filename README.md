## To generate the QR code:

Create config.json

```
{
  "clientId": "Application Client ID",
  "clientSecret": "Current application password",
  "userId": "Your national ID (11 digits)",
  "accountNr": "The account you want (11 digits)"
}
```

Run the following command

```
qrencode -l H -o config.png < config.json
```

When the password runs out (S'banken gives 3 months per password) - simply replace that and regenerate the QR code for scanning
