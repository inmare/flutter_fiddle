import express, { type Express } from "express";
import connectDB, { Artist, Song } from "./db";
import * as dotenv from "dotenv";
import { Op } from "sequelize";

dotenv.config();

const app: Express = express();
const port = 3000;

app.set("port", process.env.PORT || port);

app.get("/", (req, res) => {
    return res.send("Hello world!");
})

app.get("/api/search", async (req, res) => {
    const { text } = req.query as { text: string };
    const songs = await Song.findAll({
        where: {
            title: {
                [Op.like]: `%${text}%`
            }
        },
        include: [Artist]
    });
    return res.status(200).json(songs);
})

const startServer = async () => {
    app.listen(app.get("port"), () => {
        console.log(`서버가 ${app.get("port")}번 포트에서 실행되었습니다.`);
    })
    await connectDB();
    // 테스트용 샘플 데이터 생성
    const song = await Song.create({
        title: '당신에게 메롱',
        songLink: 'https://youtu.be/cIJmxkohX3Q',
        mrLink: 'https://drive.google.com/file/d/1odORmBdBH4fY1pbQYM7sVMkAQkOEKcsz/view?usp=sharing'
    });
    const artist = await Artist.create({ name: '히후미' });
    await song.addArtist(artist);
}

startServer();