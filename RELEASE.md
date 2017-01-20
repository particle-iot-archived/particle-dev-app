`particle-dev-app` releases are linked with [Atom releases](https://github.com/atom/atom/releases) meaning we only release versions matching exactly version of Atom which is used. As Atom's releases are more frequent, during each `particle-dev-app` release we try to update Atom to latest stable version.

# Steps

0. Create `.env` file based on [`.env.template`](.env.template)
1. Update Atom version/abi in [`.atomrc`](.atomrc)
2. Update [`particle-dev`](https://github.com/spark/particle-dev/releases) package in [`.atomrc`](.atomrc)
3. Update packages in [`inject-packages` step](build/tasks/inject-packages.coffee)
4. Run `script/build`
