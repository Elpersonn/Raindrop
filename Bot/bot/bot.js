/*
MADE BY ELPERSON 2021
Name: Raindrop mgmt bot
*/
const discord = require('discord.js')
const bcrypt = require('bcryptjs')
const { Client } = require('pg')
const client = new Client({
    user: 'admin',
    host: 'db',
    database: 'uploader',
    password: process.env.DBPASS,
    port: 5432
})
const bot = new discord.Client()
const intents = new discord.Intents()
intents.add('GUILD_MEMBERS', 'DIRECT_MESSAGES', 'GUILD_MESSAGES')
// Bot Code
var guild
bot.on('ready', () => {
    try {
        client.connect()
    }catch(error) {
        console.error('Could not connect to PSQL database: ' + error)
    }
    guild = bot.guilds.resolve('821106583928832031')
    console.log('BOT RDY')
})
bot.on('message', msg => {
    if ( msg.channel.type == 'dm' && !(msg.author.bot) ) {
        var split = msg.content.split(':')
        client.query('SELECT duserid WHERE duserid = $1', [msg.author.id], (err, res) => {
            if (res.rows[0]) {
                msg.reply(`You're already linked to an account!`)
            }
        })
        client.query('SELECT username, passwd, duserid FROM users WHERE username = $1', [split[0]], (err, res) => {
            if (err) {
                console.log(err.stack)
            }else if (!res.rows[0]) {
                msg.reply('USER NOT FOUND')
            }
            else if (res.rows[0].duserid == null) {
                if (bcrypt.compareSync(split[1], res.rows[0].passwd)) {
                    msg.reply('Credentials successfully verified!\nFor security reasons it is advised for you to delete your message.')
                    guild.members.fetch(msg.author.id).then(mem => {
                        mem.roles.add('856534805533818900', 'Passed Credential Verification')
                    })
                    
                    client.query('UPDATE users SET duserid = $1 WHERE username = $2', [msg.author.id, split[0]], (err, res) => {
                        if (err) {
                                console.error(err.stack)
                        }
                    })

                }else{
                    msg.reply('Wrong credentials!')
                }

            }else if (res.rows[0].duserid != null) {
                msg.reply('This account has been already linked!')
            }
        })
    }
})
bot.login(process.env.TOKEN)
