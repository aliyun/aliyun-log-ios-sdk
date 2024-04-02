#!/bin/sh
set -o pipefail
set -e

remote_url="git@gitee.com:aliyun-sls/aliyun-log-ios-sdk.git"
VERSION=$(cat VERSION)
echo "version: ${VERSION}"

sed -i '' "s/s.version *=.*/s.version          = \"$VERSION\"/" AliyunLogProducer.podspec
sed -i '' "s/s.version *=.*/s.version          = \"$VERSION\"/" AliyunLogOTelCommon.podspec
sed -i '' "s/s.version *=.*/s.version          = \"$VERSION\"/" AliyunLogOtlpExporter.podspec
sed -i '' "s/s.version *=.*/s.version          = \"$VERSION\"/" AliyunLogNetworkDiagnosis.podspec
sed -i '' "s/s.version *=.*/s.version          = \"$VERSION\"/" AliyunLogCrashReporter.podspec
sed -i '' "s/s.version *=.*/s.version          = \"$VERSION\"/" AliyunLogCrashReporterV1.podspec

git add VERSION
git add AliyunLogProducer.podspec
git add AliyunLogOTelCommon.podspec
git add AliyunLogOtlpExporter.podspec
git add AliyunLogNetworkDiagnosis.podspec
git add AliyunLogCrashReporter.podspec
git add AliyunLogCrashReporterV1.podspec

if [ -n "$(git diff --cached --name-only)" ]; then
    echo "Has staged changes"
    git commit -m "version: $VERSION"
else
    echo "No git changes"
fi

if git rev-parse -q --verify "refs/tags/$VERSION" >/dev/null; then
    git tag -d $VERSION
    echo "Local tag: $VERSION has deleted"
else
    echo "No local git tag: $VERSION"
fi

if git ls-remote --tags "$remote_url" | grep -qE "refs/tags/$VERSION$"; then
    git push gitee :$VERSION
    echo "Remote tag: $VERSION has deleted"
else
    echo "No remote git tag: $VERSION"
fi

git tag $VERSION
git push gitee $VERSION
    
pod repo push gitee-aliyun-sls AliyunLogProducer.podspec --allow-warnings --verbose --skip-tests --sources=https://gitee.com/aliyun-sls/Specs.git
pod repo push gitee-aliyun-sls AliyunLogOTelCommon.podspec --allow-warnings --verbose --skip-tests --sources=https://gitee.com/aliyun-sls/Specs.git
pod repo push gitee-aliyun-sls AliyunLogOtlpExporter.podspec --allow-warnings --verbose --skip-tests --sources=https://gitee.com/aliyun-sls/Specs.git
pod repo push gitee-aliyun-sls AliyunLogNetworkDiagnosis.podspec --allow-warnings --verbose --skip-tests --sources=https://gitee.com/aliyun-sls/Specs.git
pod repo push gitee-aliyun-sls AliyunLogCrashReporter.podspec --allow-warnings --verbose --skip-tests --sources=https://gitee.com/aliyun-sls/Specs.git
pod repo push gitee-aliyun-sls AliyunLogCrashReporterV1.podspec --allow-warnings --verbose --skip-tests --sources=https://gitee.com/aliyun-sls/Specs.git
