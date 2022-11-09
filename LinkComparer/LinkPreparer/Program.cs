using System.Security.Cryptography;
using System.Text;

if(args.Length < 2)
{
    Console.WriteLine("First arg - link (ex. http://localhost:8023), second image name (ex. image.jpg)");
    return;
}

var timestamp = ConvertToUnixTimestamp(DateTime.UtcNow);
var filename = args[1];
var secret = "changeme";
var method = "POST";
var load = args[0];

var data = $"{method}|{load}|{timestamp}";

var signatureArray = Encoding.UTF8.GetBytes(secret);

using var signature = new HMACSHA256(signatureArray);
signature.ComputeHash(Encoding.UTF8.GetBytes(data));

var url =
    $"curl -XPOST {load} --data-binary @{filename} -H \"Content-Type: image/jpeg\" -H \"X-Authenticate-Timestamp: {timestamp}\" -H \"X-Authenticate-Signature: {ByteToString(signature.Hash ?? Array.Empty<byte>())}\"";

Console.WriteLine(url);

static string ByteToString(byte[] buff)
{
    return buff.Aggregate("", (current, t) => current + t.ToString("x2"));
}

static long ConvertToUnixTimestamp(DateTime date)
{
    var origin = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
    var diff = date.ToUniversalTime() - origin;
    return (long) Math.Floor(diff.TotalSeconds);
}