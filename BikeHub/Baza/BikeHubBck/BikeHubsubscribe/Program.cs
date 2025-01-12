using BikeHub.Services.Database;
using EasyNetQ;
using BikeHub.Model.BicikliFM;
using BikeHub.Model.KorisnikFM;
// See https://aka.ms/new-console-template for more information

var bus = RabbitHutch.CreateBus("host=rabbitmq;virtualHost=/;username=guest;password=guest;port=5672");
await bus.PubSub.SubscribeAsync<BikeHub.Model.BicikliFM.BiciklAndEmails>("EmailBicikl", async msg =>
{
    Console.WriteLine($"Product activated: {msg.Bicikl.Naziv}");
    try
    {
        if (msg.Emails != null && msg.Emails.Any())
        {
            foreach (var email in msg.Emails)
            {
                Console.WriteLine($"Found korisnik: {email}");

                if (IsValidEmail(email))
                {
                    Console.WriteLine($"Sending email to: {email}");
                    await SendEmailAsync(email, msg.Bicikl.Naziv, (decimal)msg.Bicikl.Cijena, true);
                }
            }
        }
        else
        {
            Console.WriteLine("No users found in message.");
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error processing message: {ex.Message}");
    }
});
await bus.PubSub.SubscribeAsync<BikeHub.Model.DijeloviFM.DijeloviAndEmailscs>("EmailDijelovi", async msg =>
{
    Console.WriteLine($"Product activated: {msg.Dijelovi.Naziv}");
    try
    {
        if (msg.Emails != null && msg.Emails.Any())
        {
            foreach (var email in msg.Emails)
            {
                Console.WriteLine($"Found korisnik: {email}");

                if (IsValidEmail(email))
                {
                    Console.WriteLine($"Sending email to: {email}");
                    await SendEmailAsync(email, msg.Dijelovi.Naziv, (decimal)msg.Dijelovi.Cijena, false);
                }
            }
        }
        else
        {
            Console.WriteLine("No users found in message.");
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error processing message: {ex.Message}");
    }
});
Console.WriteLine("Listening for messages, press <return> key to close!");
Console.ReadLine();


while (true)
{
    await Task.Delay(10000);
    Console.WriteLine("Subscriber is running...");
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
    var toAddress = toEmail;
    var subject = isBicikl ? "Promjena cijene bicikla" : "Promjena cijene dijela";
    var body = isBicikl
        ? $"Bicikl koji ste sačuvali na aplikaciji '{naziv}' je upravo promijenio cijenu na '{novaCijena}'"
        : $"Dio koji ste sačuvali na aplikaciji '{naziv}' je upravo promijenio cijenu na '{novaCijena}'";

    Console.WriteLine($"Attempting to send email to: {toEmail} with subject: {subject} and body: {body}");

    try
    {
        using (var smtp = new System.Net.Mail.SmtpClient())
        {
            smtp.Host = "smtp.gmail.com";
            smtp.Port = 587;
            smtp.Credentials = new System.Net.NetworkCredential("bikehubrsii@gmail.com", "tnpj bcab mqne ivru");
            smtp.EnableSsl = true;

            var message = new System.Net.Mail.MailMessage(fromAddress, toAddress, subject, body);
            await smtp.SendMailAsync(message);
            Console.WriteLine($"Email poslan na: '{toAddress}'");
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Greška prilikom slanja emaila: {ex.Message}");
        Console.WriteLine($"Detalji greške: {ex.StackTrace}");
    }
}
