# SwJsonSchema

This class **SwJsonSchema** provides a high-level solution for **JSON Schema validation** in **Qt/C++**. It allows you to load a JSON Schema from a local path or URL and then validate JSON data (`QJsonValue`) against a wide range of **keywords** following official **JSON Schema** specifications (e.g., draft-07, 2020-12). Below is an outline of its features, focusing on user-oriented usage and key concepts.

### NOTES

To streamline its integration, the entire implementation is consolidated into a single header file, minimizing setup complexity while maintaining high performance. 
This project is actively under development, with ongoing refactoring and enhancements aimed at clarifying certain features and improving overall usability. Feedback and contributions are welcome as the library evolves to better meet user needs.

---

## Main Purpose

- **Load and parse** a JSON Schema (local file or URL: not implemented yet).
- **Validate** your JSON data against the loaded schema.
- **Support** numerous JSON Schema keywords and constructs.

## Supported Keywords (User Perspective)

### `$schema` and `$id`
- Identify the **schema version** or **base URI** for references.
- Provide context for resolution of `$ref`.

### `$ref` and `$anchor`
- **Reference** external or internal sub-schemas.
- **Anchor** specific sections of the schema to be reused or linked.

### `type`
- Constrain the data to a specific **type** (e.g., `string`, `number`, `integer`, `boolean`, `object`, `array`, `null`).

### `enum` and `const`
- **`enum`**: Restrict the data to one of the listed valid values.
- **`const`**: Enforce an **exact** match of the data to a given value.

### Numeric Constraints
- **`multipleOf`**: Data must be a multiple of the specified numeric value.
- **`minimum`/`maximum`**: Bound the data value within inclusive limits.
- **`exclusiveMinimum`/`exclusiveMaximum`**: Specify exclusive bounds.

### String Constraints
- **`minLength` / `maxLength`**: Restrict the length of the string.
- **`pattern`**: Enforce a **regular expression** match.
- **`format`**: Provide built-in checks (e.g., `email`, `date-time`, etc.).

### Object Constraints
- **`properties`**: Define specific keys and their sub-schemas.
- **`required`**: List of keys that **must** be present in the object.
- **`patternProperties`**: Match keys by **regex** patterns.
- **`additionalProperties`**: Control or prohibit extra, undeclared properties.

### Array Constraints
- **`items` / `prefixItems`**: Validate each element by a sub-schema or an ordered list of sub-schemas.
- **`additionalItems`**: Decide how to handle elements beyond `prefixItems`.
- **`minItems` / `maxItems`**: Limit the size of the array.
- **`uniqueItems`**: Prohibit **duplicate** elements.

### Combinators
- **`allOf`**: Data must satisfy **all** listed schemas.
- **`anyOf`**: Data must satisfy **at least one** listed schema.
- **`oneOf`**: Data must satisfy **exactly one** listed schema.
- **`not`**: Data must **not** match the given sub-schema.

### Conditional Keywords
- **`if`**: Trigger a conditional check.
- **`then` / `else`**: Apply specific sub-schemas depending on whether the `if` sub-schema is satisfied.

### `$defs` or `definitions`
- Store named sub-schemas within the same file for referencing internally or externally.

### Custom Keywords
- Ability to **register** and handle **custom** JSON Schema keywords, enabling user-defined validations for special use-cases.

---

## Typical User Workflow

1. **Create** a `SwJsonSchema` instance by passing a JSON Schema source (file path or URL).
2. **Check** if the schema loaded successfully.
3. **Validate** any `QJsonValue` data against the schema using a straightforward validation call.
4. **Inspect** possible error messages if validation fails.

---

## Additional Notes

- **JSON Schema Registry**: Maintains a collection of schemas to resolve cross-references (`$ref`) without repeatedly parsing the same file.
- **Compatibility**: Aims to support JSON Schema features (draft-07, 2020-12, etc.) commonly required in modern applications.
- **Extensibility**: Custom keywords can be registered to address domain-specific checks beyond standard JSON Schema keywords.

---


- *Qt JSON Schema*, *JSON validation in C++*, *Qt JSON validation*, *JSON Schema registry*, *custom keywords*, *allOf*, *anyOf*, *oneOf*, *JSON Schema draft-07*, *2020-12*, *$defs*, *$anchor*, *type constraints*, *schema references*, *string constraints*, *object properties*, *array validation*, *Qt/C++ data validation*, *format checks*, *regular expressions*.

---
