
# Strangler: Playing With Feature Flags In ColdFusion

At [work][invision], I [use and **love** LaunchDarkly][blog-3766] as our feature flag system. However, with the high-_value_ of LaunchDarkly comes a relatively high-_cost_; at least, it's "high" when you consider using feature flags in a personal project that doesn't make any money. As such, I wanted to see if I could create a _LaunchDarkly-inspired_ feature flag system for my personal ColdFusion blog.

This repository represents a **proof-of-concept** running in [Lucee CFML][lucee-cfml]. It contains two separate ColdFusion applications:

* **Admin** - located at `/admin/`.
* **Demo** - located at `/`.

Both ColdFusion applications load the same data file - a JSON file - that contains the feature flag information. The Admin application is used to create feature flags and update the targeting. The Demo application is used to apply that targeting against a set of sample users.

The Demo app runs as a `<frameset>` with the Demo on the left and the Admin on the right:

... demo to be added ...


## Running With CommandBox

This demo runs on Lucee CFML using CommandBox. To start the demo, `cd` into this folder and following these steps:

```sh
# Open the CommandBox CLI.
box

# Step down into the code directory.
cd ./code/

# Starts the Lucee CFML server (uses server.json by default)
# and opens it in your default browser.
start
```


[blog-3766]: https://www.bennadel.com/blog/3766-my-personal-best-practices-for-using-launchdarkly-feature-flags.htm "Read article: My Personal Best Practices For Using LaunchDarkly Feature Flags"

[invision]: https://www.invisionapp.com/

[lucee-cfml]: https://www.lucee.org/
