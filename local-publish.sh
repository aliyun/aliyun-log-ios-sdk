#!/bin/sh
set -o pipefail
set -e

VERSION=$(cat VERSION)
echo "version: ${VERSION}"

sed -i '' "s/s.version *=.*/s.version          = \"$VERSION\"/" AliyunLogProducer.podspec
sed -i '' "s/s.version *=.*/s.version          = \"$VERSION\"/" AliyunLogOTelCommon.podspec
sed -i '' "s/s.version *=.*/s.version          = \"$VERSION\"/" AliyunLogOtlpExporter.podspec
sed -i '' "s/s.version *=.*/s.version          = \"$VERSION\"/" AliyunLogNetworkDiagnosis.podspec
sed -i '' "s/s.version *=.*/s.version          = \"$VERSION\"/" AliyunLogCrashReporter.podspec

git add VERSION
git add AliyunLogProducer.podspec
git add AliyunLogOTelCommon.podspec
git add AliyunLogOtlpExporter.podspec
git add AliyunLogNetworkDiagnosis.podspec
git add AliyunLogCrashReporter.podspec

if [ -n "$(git diff --cached --name-only)" ]; then
    echo "Has staged changes"
    git commit -m "version: $VERSION"
else
    echo "No git changes"
fi

if git rev-parse -q --verify "refs/tags/$VERSION" >/dev/null; then
    git tag -d $VERSION
    git push gitee :$VERSION
    echo "tag: $VERSION deleted"
else
    echo "No git tag"
fi

git tag $VERSION
git push gitee $VERSION
    
pod repo push gitee-aliyun-sls AliyunLogProducer.podspec --allow-warnings --verbose --skip-tests --sources=https://gitee.com/aliyun-sls/Specs.git
pod repo push gitee-aliyun-sls AliyunLogOTelCommon.podspec --allow-warnings --verbose --skip-tests --sources=https://gitee.com/aliyun-sls/Specs.git
pod repo push gitee-aliyun-sls AliyunLogOtlpExporter.podspec --allow-warnings --verbose --skip-tests --sources=https://gitee.com/aliyun-sls/Specs.git
pod repo push gitee-aliyun-sls AliyunLogNetworkDiagnosis.podspec --allow-warnings --verbose --skip-tests --sources=https://gitee.com/aliyun-sls/Specs.git
pod repo push gitee-aliyun-sls AliyunLogCrashReporter.podspec --allow-warnings --verbose --skip-tests --sources=https://gitee.com/aliyun-sls/Specs.git
