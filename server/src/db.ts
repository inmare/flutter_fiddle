import { DataTypes, HasManyAddAssociationMixin, Model, NonAttribute, Sequelize } from "sequelize";

const sequelize = new Sequelize('karaoke', 'postgres', process.env.DB_PASSWORD, {
    host: "localhost",
    dialect: "postgres",
});

class Song extends Model {
    declare id: number;
    declare title: string;
    declare songLink: string;
    declare mrLink: string;
    // 여러 개의 Artist를 가질 수 있음
    declare addArtist: HasManyAddAssociationMixin<Artist, number>;
}

class Artist extends Model {
    declare id: number;
    declare name: string;
}

// Song 모델 정의
Song.init({
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    title: { type: DataTypes.STRING, allowNull: false },
    songLink: { type: DataTypes.STRING, allowNull: false },
    mrLink: { type: DataTypes.STRING, allowNull: false }
}, {
    sequelize,
    freezeTableName: true,
});

// Artist 모델 정의
Artist.init({
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    name: { type: DataTypes.STRING, allowNull: false },
}, {
    sequelize,
    freezeTableName: true,
});

export { Song, Artist };

// Song과 Artist는 다대다 관계
Song.belongsToMany(Artist, { through: 'SongArtist' });
Artist.belongsToMany(Song, { through: 'SongArtist' });

export default async function connectDB() {
    try {
        await sequelize.authenticate();
        // 데이터베이스 동기화
        await sequelize.sync({ force: true, alter: process.env.NODE_ENV === "development" });
        console.log("데이터베이스 연결 성공");
    } catch (error) {
        console.error("데이터베이스 연결 실패: ", error);
    }
}
