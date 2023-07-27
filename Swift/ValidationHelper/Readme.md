## ValidationHelper Class 

The `ValidationHelper` class in our Swift codebase provides a suite of functions designed to help with various types of data validations. This class comes with robust methods to perform validation tasks commonly required in app development, such as validating email addresses, mobile numbers, and text fields.

Key methods in the `ValidationHelper` class include:

- `fieldvalidation(...)`: Checks if specified text fields are empty or data objects are nil, and sets appropriate error messages.
- `validateEmail(...)`: Validates email addresses using a regular expression.
- `shouldValidateTextFor(...)`: Validates a text string based on specified criteria such as Unicode ranges, presence of emojis, digits, and whitespaces.
- `formatMobileNumber(...)`: Formats a mobile number according to a specified format.
- `validateMobileNumber(...)`: Validates the length of a mobile number based on its prefix.

These helper functions are designed to be flexible and efficient, saving you the effort of repeatedly writing validation logic for common tasks. By simply passing in the required parameters, you can effectively validate data and ensure the integrity of user inputs in your app. 

**Note:** Always ensure to use these methods as per your project's requirement and modify them if needed to suit your specific validation needs.