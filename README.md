# Resin Fedora base images

## Description

This is the repository of ARMv7(armhf) Fedora Docker base images. These images are generated from minimal armhfp Fedora disk images [(ref)][disk-image-example]. For details about available tags, see [here][armhf-dockerhub].

## Issues

- DNF (the new package manager) is not working on armhf images so you shouldn't use it. Please use yum instead.
- Yum is removed since Fedora 23 so we don't support Fedora 23 or higher versions until DNF issue is resolved.

## Contribute

- Issue Tracker: [github.com/resin-io-library/resin-fedora/issues][issue-tracker]
- Source Code: [github.com/resin-io-library/resin-fedora][source-code]

## Support

If you're having any problem, please [raise an issue][issue-tracker] on GitHub.

If you're having any problem, please [raise an issue][issue-tracker] on GitHub.

[disk-image-example]:http://download.fedoraproject.org/pub/fedora/linux/releases/22/Images/armhfp/
[armhf-dockerhub]:https://registry.hub.docker.com/u/resin/armhf-fedora/
[source-code]:https://github.com/resin-io-library/resin-fedora
[issue-tracker]:https://github.com/resin-io-library/resin-fedora/issues
