## 1️⃣ NestJS 프로젝트 생성

Nest CLI를 사용하여 기본 프로젝트 생성 후 Yarn 기반으로 패키지 관리.

```bash
nest new backend
```

---

## 2️⃣ Prisma 설치 및 초기 설정

```bash
yarn add -D prisma
yarn add @prisma/client
yarn prisma init
```

Prisma 7부터는 `schema.prisma`에 직접 DB URL을 작성하지 않고  
`prisma.config.ts`에서 관리하도록 변경됨.

---

## 3️⃣ Prisma 7 설정 구조

### 📁 prisma/schema.prisma

```prisma
datasource db {
  provider = "postgresql"
}

generator client {
  provider = "prisma-client-js"
}
```

### 📁 prisma.config.ts

```ts
import 'dotenv/config';
import { defineConfig, env } from 'prisma/config';

export default defineConfig({
  schema: 'prisma/schema.prisma',
  datasource: {
    url: env('DATABASE_URL'),
  },
});
```

---

## 4️⃣ 기존 PostgreSQL DB Introspection

기존에 생성되어 있던 `smart_mini_mes` 데이터베이스의 테이블을 Prisma로 가져옴.

```bash
yarn prisma db pull
yarn prisma generate
```

또는

```bash
yarn db
```

### package.json scripts

```json
"prisma:pull": "prisma db pull",
"prisma:generate": "prisma generate",
"prisma:migrate": "prisma migrate dev",
"db": "yarn prisma:pull && yarn prisma:generate"
```

총 21개 테이블 모델을 Prisma 스키마로 자동 생성.

---

## 5️⃣ Prisma 7 Adapter 설정 (중요)

Prisma 7부터는 직접 DB 연결 시 Adapter 설정 필요.

### 설치

```bash
yarn add pg
yarn add @prisma/adapter-pg
```

### 📁 prisma.service.ts

```ts
import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  constructor() {
    const pool = new Pool({
      connectionString: process.env.DATABASE_URL,
    });

    super({ adapter: new PrismaPg(pool) });
  }

  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
```

---

## 6️⃣ ValidationPipe 설정

Nest 실행 시 `class-validator` 누락 에러 발생 → 패키지 설치

```bash
yarn add class-validator class-transformer
```

---

## 7️⃣ 서버 실행

```bash
yarn start
```

정상적으로 PostgreSQL 연결 및 Nest 서버 구동 완료.

---

# 📂 현재 DB 모델 목록

Prisma Introspection 결과 (일부)

- tb_mes_user000
- tb_mes_user_role010
- tb_mes_ord000
- tb_mes_ord100
- tb_mes_opr000
- tb_mes_opr_step100
- tb_mes_lot000
- tb_mes_item100
- tb_mes_prcs_template100
- tb_mes_sensor_reading000
- tb_mes_alarm000
- tb_mes_claim000
- tb_mes_equip000
- tb_mes_dept000
- tb_mes_role000
- tb_mes_refresh_token000
- tb_mes_unit_prcs110
- tb_mes_prcs_dept_his010
- tb_mes_cnpt000
- tb_mes_file000
- tb_mes_item_template_map120

---

# 🔥 현재 완료 상태

- ✅ NestJS 서버 구축 완료
- ✅ Prisma 7 연동 완료
- ✅ PostgreSQL 연결 완료
- ✅ 기존 DB 테이블 Prisma 모델화 완료
- ✅ Adapter 기반 DB 연결 적용
- ✅ ValidationPipe 환경 구성 완료

---

# 🚀 다음 개발 예정

- 사용자 인증 (JWT)
- 공정(OPR) 생성 로직
- LOT 생성 및 생산 흐름 관리
- 트랜잭션 기반 생산 데이터 처리
- Raw Query + Prisma 혼합 전략 설계

---

# ⚠️ 참고 사항

- Prisma 7부터 `schema.prisma`에 `url` 사용 불가
- 반드시 `prisma.config.ts`에서 datasource 관리
- Adapter 설정 없으면 런타임 연결 실패
- 운영 DB 연결 시 `migrate dev` 사용 주의

---

# 👩‍💻 Author

Smart Factory Mini MES Backend Development
