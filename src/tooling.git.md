### Git branching model `[tooling.git]`

We strive to follow [trunk-based development](https://trunkbaseddevelopment.com/) with few caveats.
Since the cost of introducing correctness (or security) issues in our software is very high, we don't welcome even temporary quality regressions or sources of risk within our main branch. This may lead to feature branches that are a bit longer-lived than the trunk-based development ideal of 2 to 3 days.

Generally, all significant code changes are reviewed by at least one team member and must pass CI.

* For style and other trivial fixes, no review is needed (passing CI is sufficient).
* For small ideas, use a PR.
* For big ideas, create a RFC issue describing the goals before too much time is committed to the implementation.

Feature branches are usually squashed and rebased upon merge to facilitate easier revering in case of discovered problems.

Work on big ideas is divided into smaller, at most week-sized, chunks that each reasonably can be digested and reviewed in one sitting - the output here might be an overview, a prototype or progress towards a milestone or a snapshot of the work done so far, with the aim to involve reviewers early and allow space and time for course adjustments as the idea develops.

Uncontested portions of the developed code that don't introduce significant risks or can be properly gated through feature flags are merged as soon as possible in order to reduce the size of the long-lived feature branch. Compile-time feature flags are preferred to run-time feature flags.

## Release strategy

The repositories of our mature projects should feature the following named branches:

* `unstable` - the trunk branch where new feature branches are merged.

* `testing` - a branch carrying a release candidate build usually selected as a recent commit from `unstable`. It exists mostly to facilitate the deployment and testing of release candidates. Since this branch points to commits from `unstable`, it is usually updated before each release with a fast-forward push. Creating additional release-specific commits in the branch is not encouraged, but rare situations may require cherry-picking additional commits from unstable.

* `stable` - Usually updated with a fast-forward push from `testing` once the release candidate has been deemed stable enough and the release has been tagged and published. Usually, the tagged commit is directly taken from the `unstable` branch, but in case some additional commits were introduced to `testing` in preparation of the release, the `stable` branch must be merged back into `unstable` immediately after the release.

