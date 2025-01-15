using System.Text;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text.Json;

Console.WriteLine("Listening for messages, press <return> key to close!");

var factory = new ConnectionFactory
{
    HostName = "rabbitmq",
    VirtualHost = "/",
    UserName = "guest",
    Password = "guest",
    Port = 5672
};

using var connection = factory.CreateConnection();
using var channel = connection.CreateModel();

// Pretplata na "EmailBicikl"
channel.QueueDeclare(queue: "EmailBicikl", durable: true, exclusive: false, autoDelete: false, arguments: null);

var consumerBicikl = new EventingBasicConsumer(channel);
consumerBicikl.Received += async (model, ea) =>
{
    var body = ea.Body.ToArray();
    var message = Encoding.UTF8.GetString(body);

    Console.WriteLine($"Primljena poruka za bicikl: {message}");

    try
    {
        var biciklMsg = JsonSerializer.Deserialize<BikeHub.Model.BicikliFM.BiciklAndEmails>(message);
        if (biciklMsg != null)
        {
            foreach (var email in biciklMsg.Emails)
            {
                if (IsValidEmail(email))
                {
                    await SendEmailAsync(email, biciklMsg.Bicikl.Naziv, biciklMsg.Bicikl.Cijena.GetValueOrDefault(), true);
                }
            }
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Greška prilikom obrade poruke za bicikl: {ex.Message}");
    }
};
channel.BasicConsume(queue: "EmailBicikl", autoAck: true, consumer: consumerBicikl);

// Pretplata na "EmailDijelovi"
channel.QueueDeclare(queue: "EmailDijelovi", durable: true, exclusive: false, autoDelete: false, arguments: null);

var consumerDijelovi = new EventingBasicConsumer(channel);
consumerDijelovi.Received += async (model, ea) =>
{
    var body = ea.Body.ToArray();
    var message = Encoding.UTF8.GetString(body);

    Console.WriteLine($"Primljena poruka za dijelove: {message}");

    try
    {
        var dijeloviMsg = JsonSerializer.Deserialize<BikeHub.Model.DijeloviFM.DijeloviAndEmailscs>(message);
        if (dijeloviMsg != null)
        {
            foreach (var email in dijeloviMsg.Emails)
            {
                if (IsValidEmail(email))
                {
                    await SendEmailAsync(email, dijeloviMsg.Dijelovi.Naziv, dijeloviMsg.Dijelovi.Cijena.GetValueOrDefault(), false);
                }
            }
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Greška prilikom obrade poruke za dijelove: {ex.Message}");
    }
};
channel.BasicConsume(queue: "EmailDijelovi", autoAck: true, consumer: consumerDijelovi);

// Main Loop
while (true)
{
    Console.WriteLine("Subscriber is running...");
    await Task.Delay(10000);
}

bool IsValidEmail(string email)
{
    try
    {
        var addr = new System.Net.Mail.MailAddress(email);
        return addr.Address == email;
    }
    catch
    {
        return false;
    }
}

async Task SendEmailAsync(string toEmail, string naziv, decimal novaCijena, bool isBicikl)
{
    var fromAddress = "bikehubrsii@gmail.com";
    var subject = isBicikl ? "Promjena cijene bicikla" : "Promjena cijene dijela";
    var body = isBicikl
        ? $"Bicikl koji ste sačuvali na aplikaciji '{naziv}' je upravo promijenio cijenu na '{novaCijena}'"
        : $"Dio koji ste sačuvali na aplikaciji '{naziv}' je upravo promijenio cijenu na '{novaCijena}'";

    try
    {
        using var smtp = new System.Net.Mail.SmtpClient("smtp.gmail.com", 587)
        {
            Credentials = new System.Net.NetworkCredential("bikehubrsii@gmail.com", "tnpj bcab mqne ivru"),
            EnableSsl = true
        };

        using var message = new System.Net.Mail.MailMessage(fromAddress, toEmail, subject, body);
        await smtp.SendMailAsync(message);

        Console.WriteLine($"Email poslan na: '{toEmail}'");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Greška prilikom slanja emaila: {ex.Message}");
    }
}
