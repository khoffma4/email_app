# Email App #

This is a small web application that takes API requests, formats the data, and sends the requests to either Mandrill or Mailgun via their APIs. The app allows you to abstract away the details of the Mandrill and Mailgun APIs, and allows for quick a failover when one of those services goes down.

This is what the app does:

 - Accepts POST requests with JSON data to a "/email" endpoint
 - Validates the payload inputs
 - Converts the body (HTML) to a plain text version
 - Abstracts away sending an HTTP request to Mandrill's API to create an email
 - Abstracts away sending an HTTP request to Mailgun's API to create an email
 - Allows you to quickly change email services by changing configurations and restarting your server


### To use: ###

1. To clone the repo run `git clone https://github.com/khoffma4/email_app.git`

2. Install ruby 2.5.1 and the bundler gem if they are not already installed.

3. Run `bundle install` to install the required gems

4. Set the following environment variables in config/application.yml

    - `MANDRILL_API_KEY`: Your API key for Mandrill. Found at https://mandrillapp.com/settings.

    - `MAILGUN_API_KEY`: Your API key for Mailgun. Found at https://app.mailgun.com/app/account/security.

    - `MAILGUN_DOMAIN`: The domain you are sending emails from. Your domains can be found here https://app.mailgun.com/app/domains. For non-production use, you should have an automatically provisioned sandbox domain.

    - `MAILGUN_SANDBOX_EMAIL`: If you are using a sandbox domain, Mailgun requires you to add and verify email addresses that will be allowed to recieve emails from the sandbox. You can set this up here: https://app.mailgun.com/app/account/authorized.

    - `EMAIL_CLIENT`: This is how you can configure the app to use a specific email service. The two valid values are "Madnrill" and "Mailgun".

5. Run the server using `rails server`.

### How to run the tests ###

In terminal, run `rspec spec/` to run all the specs. You will need to set config variables in in `config/application_test.yml` or change `config/environment/test.rb` to load variables from `config/application.yml`

### Design Considerations ###

I built this in Ruby because that is one of the languages that I know well, and Ruby has many open source libraries that would work well for this application. It makes sense to build on top of existing, well-tested, libraries instead of reinventing the wheel.

A big consideration in this design choice is whether or not the application needs to be flexible towards future requirement changes and additions. If I was fairly certain the requirements for this application would not grow in the future, a simple rack app or lightweight framework would be able to meet all the requirements. However it would make things more difficult in the future as new requirements are added to the app. Another consideration is that the application will be going into production, so things like security, authentication, and scalability need to be kept in mind.

I chose to use Rails (5.2), because it provides many abstractions that will make development quicker and make it easier to be production-ready. I considered using a lightweight ruby frameworks like Sinatra or Grape. It seemed like those both would take a little extra work to get them ready for production and would be more of a hassle as requirements are added in the future.

While Rails may seem bloated for this small app, it is possible to not require the components that we do not need. When creating the app, I used the `--api` flag to creates the application with less middleware than a full rails app, leaving out things like the asset pipeline, `ActionDispatch::Cookies`, `ActionDispatch::Session::CookieStore`, and `ActionDispatch::Flash`. I also left out ActiveRecord, ActiveStorage, ActionMailer, ActionCable, and ActiveJob from being loaded with the app. This is a good balance between using a lightweight framework, but allowing for flexibility in the future.

Rails 5.2 comes with the Puma web server out of the box. Puma allows us to spin up multiple workers to handle requests concurrent requests. Puma can process requests in parallel with Rubinius and JRuby.

### Production Considerations ###

- API requests to email providers should be sent using a background task. This would make API requests to this application (`POST /email`) quicker because it would simply enqueue the job and respond with a message saying that it was added to the queue. It would be able to meet periods of high demand because the web server would not get held up sending the email request to the email service. It would also make it easier to handle failed API requests to the email service. Background jobs that fail can be added back to the queue, which would lead to fewer "lost" emails.

- This API endpoint needs to be secured and only authorize requests from trusted sources.

- Set up logging service and bug notifications


### Possible Improvements ###

- Stub the Mandrill and Mailgun APIs for testing

- Make API calls to Mandrill and Mailgun using a background process

- Use the Neverbounce API to validate email addresses. This service pings email clients to predict whether an email address will bounce or be accepted. This helps prevent your email server from gaining a bad reputation with ISPs and email clients.

- Store emails in a database so you can easily check on emails that were sent. That way all emails are in one place, regardless of which sevice they were sent through.

- Set up webhooks to receive email events objects from Mandrill and Mailgun. These can be stored in a  database so you can see which emails were acutally delivered. If an email bounced, you should know that it did and the reason why.

- Build a dashboard for customer support to check on emails that were delivered to clients. When customers ask why they haven't received an email this allows customer support to double check that it was sent and helps them figure out what may have went wrong if it was not sent.


