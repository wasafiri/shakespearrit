# Shakespearrit

Shakespearrit is a web application dedicated to the works of William Shakespeare, with a unique focus on providing a platform for American Sign Language (ASL) interpretations of his plays. Users can browse the complete texts of Shakespeare's plays, view user-submitted ASL video interpretations for specific lines, and contribute their own interpretations.

## Features

*   **Browse Plays:** Read the full text of all of Shakespeare's plays, structured by acts and scenes.
*   **ASL Interpretations:** Watch user-submitted YouTube videos of ASL interpretations for individual lines.
*   **User Accounts:** Register for an account, log in, and manage your profile.
*   **Contribute:** Submit your own ASL interpretations by providing a YouTube link for a specific line or lines. 
*   **Voting:** Upvote or downvote interpretations to help highlight the best ones.
*   **Search:** Search for plays, specific lines, or interpretations.
*   **Achievements:** Earn badges for your contributions to the community.
*   **Admin Panel:** A comprehensive admin dashboard to manage plays, users, and interpretations.

## Tech Stack

*   **Backend:** Ruby with the [Roda](http://roda.jeremyevans.net/) web framework.
*   **Database:** [PostgreSQL](https://www.postgresql.org/) with the [Sequel](http://sequel.jeremyevans.net/) ORM.
*   **Authentication:** [Bcrypt](https://github.com/bcrypt-ruby/bcrypt-ruby) for password hashing.
*   **Pagination:** [Pagy](https://github.com/ddnexus/pagy) for efficient pagination.
*   **Testing:** [RSpec](https://rspec.info/) for testing.

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

*   Ruby
*   Bundler
*   PostgreSQL

### Installation

1.  Clone the repo
    ```sh
    git clone https://github.com/your_username_/Shakespearrit.git
    ```
2.  Install Ruby gems
    ```sh
    bundle install
    ```
3.  Create a `.env` file and set the following environment variables:
    ```
    SESSION_SECRET=your_session_secret
    CSRF_SECRET=your_csrf_secret
    DATABASE_URL=postgres://user:password@host/database_name
    ```

### Database Setup

1.  Create the database:
    ```sh
    createdb shakespearrit_development
    ```
2.  Run the migrations:
    ```sh
    rake db:migrate
    ```

### Running the Application

Start the development server:
```sh
rackup
```

The application will be available at `http://localhost:9292`.

## Testing

This project uses **Minitest:** for the API and features outlined in the `TODO.md` document. These tests serve as a living specification for the application's evolution.

### Running the New Minitest Feature Suite

The new feature tests are located in the `test/` directory and are designed to guide new development. To run them, you will first need to add a test task to the `Rakefile`.

Add the following to your `Rakefile`:
```ruby
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

task default: :test
```

Once the `Rakefile` is updated, you can run the entire Minitest suite with:

```sh
rake test
```

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request
