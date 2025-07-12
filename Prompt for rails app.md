Prompt for rails app:

Using mise locally for ruby and bundler for gem installation. Create a new rails engine in a subdirectory of the current directory after installing the necessary gems using bundler to do so.

You are a senior rails developer. You are given a prompt and you need to implement the prompt in ruby gem following all best practices and design patterns that can be used as a rails engine in versions of rails down to 4.2.

I want to create a rails engine that allows the user to intercept all errors and store them in a database. The engine should provide the following features:

The engine should be named VibeErrors.

It should include the following:

- an api to create errors. The api should be able to create errors from any exception. Errors should be able to be tagged and given a severity.
- an api to create messages. The api should be able to create messages from any message. Messages should be able to be tagged and given a severity.
- a web interface to view the errors
- a web interface to search through the errors
- a way to tag errors at the time of creation
- a way to tag errors after the fact
- a way to search through the errors by tag
- a way to search through the errors by severity
- a way to search through the errors by location
- a way to search through the errors by message
- a way to search through the errors by stack trace
- a way to assign an owner to an error
- a way to assign a team to an error
- a way to assign a project to an error
- a way to assign a status to an error
- a way to assign a priority to an error
- a way to assign a due date to an error
- a way to assign a resolution to an error
- a way to assign ownership of an error based on the origination point of the exception. An exception should be tracable to the last point in the code that has an owner in the stack trace and that owner should be tagged as the owner of the error.

- the application should be written with Ruby 3.4 and the lasest stable version of rails. Rspec should be used for testing. All code should have 100% unit test coverage. There should be an integration test suite that tests the engine in a rails app. A sample rails app should be provided to test the engine.

The engine should be able to be used in any rails app. There should be an easy way to install the engine in any rails app using a generator and a rake task to run the engine. Routes should be added to the rails app to allow the engine to be used.

A well written README.md file should be provided with the engine.

A well written CHANGELOG.md file should be provided with the engine.

A well written LICENSE.md file should be provided with the engine.

A well written CONTRIBUTING.md file should be provided with the engine.

The engine should be able to integrate with a CI/CD pipeline in github actions. The pipeline should run the tests and deploy the engine to a test environment (Hanami).

Use the standardrb gem to format the code.

Use the rubocop gem to enforce the code style.

Use the reek gem to enforce the code smell.

Use the brakeman gem to enforce the security.



