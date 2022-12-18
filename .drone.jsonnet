local getCondition = function(branchName, event) {
    instance: "ec2-3-87-144-94.compute-1.amazonaws.com",
    event: event,
};


local build = function(branchName) {
    name: 'Build',
    image: 'maven:3.6.3-adoptopenjdk-11',
    pull: 'if-not-exists',
    commands: [
        'mvn package'
    ]
};

local publishReferPal = function(branchName)  {
    name: 'Publish',
    image: 'plugins/docker',
    pull: 'if-not-exists',
    settings: {
        username: {
            from_secret: 'wangjinyin1234',
        },
        password: {
            from_secret: 'Wangjinyin521@',
        },
        repo: 'wangjinyin1234/referPal',
        tags: '${DRONE_COMMIT_SHA:0:8}',
        dockerfile: './referPal/Dockerfile',
        context: './api-server',
    },
    when: {
        instance: "ec2-3-87-144-94.compute-1.amazonaws.com",
        event: [
            'push'
        ],
   }
};

local deployReferPal = function(branchName)  {
    name: 'Deploy',
    image: 'docker',
    pull: 'if-not-exists',
    commands: [
        'docker run --name referPal -it -p 80:80 wangjinyin1234/referPal'
    ]
};


local deployPipeline = function(branchName) {
 kind: 'pipeline',
 name: branchName + '_deployment',
 steps: if branchName == 'test' then [
    build(branchName),
    publishReferPal(branchName),
    deployReferPal(branchName),
 ],
 trigger: {
    branch: branchName,
 }
};

[deployPipeline('test')]
