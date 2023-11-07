const fs = require('fs')
const { execSync } = require('child_process')

const config = JSON.parse(fs.readFileSync('package.json').toString())

logAndExec(`yarn remove ${params(config.dependencies)}`)
logAndExec(`yarn remove -D ${params(config.devDependencies)}`)
logAndExec(`rm yarn.lock`)

logAndExec(`yarn add ${params(config.dependencies)}`)
logAndExec(`yarn add -D ${params(config.devDependencies)}`)

function logAndExec(command) {
  console.log(command)
  execSync(command)
}

function params(object) {
  const array = []
  for (const dependencie in object) {
    array.push(dependencie)
  }
  return array.join(' ')
}
