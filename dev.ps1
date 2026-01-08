# Script pour lancer Strapi CRM avec le tunnel SSH automatiquement

Write-Host "[*] Eclipse CRM Backend - Demarrage..." -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] Verification du tunnel SSH..." -ForegroundColor Cyan

# Teste si le port 3307 repond vraiment (pas juste si un process ecoute)
$tunnelWorking = $false
try {
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $tcpClient.Connect("127.0.0.1", 3307)
    $tcpClient.Close()
    $tunnelWorking = $true
} catch {
    $tunnelWorking = $false
}

if (-not $tunnelWorking) {
    Write-Host "[>] Lancement du tunnel SSH vers le VPS..." -ForegroundColor Yellow
    
    # Lance le tunnel SSH en arriere-plan
    Start-Process -NoNewWindow -FilePath "ssh" -ArgumentList "-N", "arthur-vps"
    
    # Attend que le tunnel soit etabli
    Write-Host "[*] Attente de l'etablissement du tunnel..." -ForegroundColor Gray
    $retries = 0
    $maxRetries = 10
    while ($retries -lt $maxRetries) {
        Start-Sleep -Seconds 1
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $tcpClient.Connect("127.0.0.1", 3307)
            $tcpClient.Close()
            break
        } catch {
            $retries++
        }
    }
    
    if ($retries -ge $maxRetries) {
        Write-Host "[ERREUR] Impossible d'etablir le tunnel SSH" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "[OK] Tunnel SSH etabli sur le port 3307" -ForegroundColor Green
} else {
    Write-Host "[OK] Tunnel SSH deja actif" -ForegroundColor Green
}

Write-Host ""
Write-Host "[>] Lancement de Strapi CRM (port 1338)..." -ForegroundColor Cyan
Write-Host ""

# Lance Strapi
pnpm dev

