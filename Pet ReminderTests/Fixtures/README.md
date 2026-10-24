# Original V4 store

`OriginalV4.store` was generated on an iOS 27 simulator using the models from
commit `81b6326`, before the App Intents changes. It contains one synthetic pet
(`Shipped V4`), one completed morning feeding, and one vaccine. CloudKit was
disabled. SQLite's backup API consolidated committed WAL data into this file.

The fixture tests compatibility with the original persisted model metadata,
including the originally unversioned feed and vaccine types. Do not regenerate
it using the current historical schemas: that would lose this coverage.
