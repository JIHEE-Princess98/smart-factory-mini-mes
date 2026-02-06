CREATE TABLE IF NOT EXISTS tb_mes_dept000 (
  dept_cd     VARCHAR(50) PRIMARY KEY,
  dept_nm     VARCHAR(100) NOT NULL,
  use_yn      CHAR(1) NOT NULL DEFAULT 'Y',
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE tb_mes_dept000 IS '부서 마스터';
COMMENT ON COLUMN tb_mes_dept000.dept_cd IS '부서 코드(PK)';
COMMENT ON COLUMN tb_mes_dept000.dept_nm IS '부서명';
COMMENT ON COLUMN tb_mes_dept000.use_yn IS '사용 여부(Y/N)';
COMMENT ON COLUMN tb_mes_dept000.created_at IS '생성일시';

CREATE TABLE IF NOT EXISTS tb_mes_user000 (
  user_id        VARCHAR(50) PRIMARY KEY,
  user_nm        VARCHAR(100),
  user_type_cd   VARCHAR(50),
  password_hash  VARCHAR(255) NOT NULL,
  mbl_tel_no     VARCHAR(20),
  mbl_email      VARCHAR(100),
  dept_cd        VARCHAR(50), 
  jbpgd_nm       VARCHAR(50),
  user_rmrk      VARCHAR(2000),
  ip             VARCHAR(50),
  use_yn         CHAR(1) NOT NULL DEFAULT 'Y',
  del_yn         CHAR(1) NOT NULL DEFAULT 'N',
  last_login_at  TIMESTAMP,
  created_by     VARCHAR(50),
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by     VARCHAR(50),
  updated_at     TIMESTAMP
);

COMMENT ON TABLE tb_mes_user000 IS '사용자 계정';
COMMENT ON COLUMN tb_mes_user000.user_id IS '사용자 ID';
COMMENT ON COLUMN tb_mes_user000.password_hash IS '비밀번호 해시';
COMMENT ON COLUMN tb_mes_user000.dept_cd IS '부서 코드';
COMMENT ON COLUMN tb_mes_user000.use_yn IS '사용 여부';
COMMENT ON COLUMN tb_mes_user000.del_yn IS '삭제 여부';
COMMENT ON COLUMN tb_mes_user000.last_login_at IS '마지막 로그인 일시';

CREATE INDEX IF NOT EXISTS idx_user_dept_cd ON tb_mes_user000(dept_cd);

CREATE TABLE IF NOT EXISTS tb_mes_role000 (
  role_cd    VARCHAR(50) PRIMARY KEY,
  role_nm    VARCHAR(100) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE tb_mes_role000 IS '역할(Role) 마스터';
COMMENT ON COLUMN tb_mes_role000.role_cd IS '역할 코드(PK)';
COMMENT ON COLUMN tb_mes_role000.role_nm IS '역할명';

CREATE TABLE IF NOT EXISTS tb_mes_user_role010 (
  user_id     VARCHAR(50) NOT NULL, 
  role_cd     VARCHAR(50) NOT NULL, 
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, role_cd)
);

COMMENT ON TABLE tb_mes_user_role010 IS '사용자-역할 매핑(N:M)';
COMMENT ON COLUMN tb_mes_user_role010.user_id IS '사용자 ID';
COMMENT ON COLUMN tb_mes_user_role010.role_cd IS '역할 코드';

CREATE INDEX IF NOT EXISTS idx_user_role_role_cd ON tb_mes_user_role010(role_cd);


CREATE TABLE IF NOT EXISTS tb_mes_refresh_token000 (
  token_id    UUID PRIMARY KEY,
  user_id     VARCHAR(50) NOT NULL, 
  token_hash  VARCHAR(255) NOT NULL,
  expires_at  TIMESTAMP NOT NULL,
  revoked_at  TIMESTAMP,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE tb_mes_refresh_token000 IS '리프레시 토큰 저장(재발급 시 DB 최신 사용자 반영용)';
COMMENT ON COLUMN tb_mes_refresh_token000.token_id IS '토큰 PK(UUID)';
COMMENT ON COLUMN tb_mes_refresh_token000.user_id IS '사용자 ID';
COMMENT ON COLUMN tb_mes_refresh_token000.token_hash IS '리프레시 토큰 해시';
COMMENT ON COLUMN tb_mes_refresh_token000.revoked_at IS '폐기 시각';

CREATE INDEX IF NOT EXISTS idx_refresh_token_user_id ON tb_mes_refresh_token000(user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_token_expires_at ON tb_mes_refresh_token000(expires_at);

-- =========================================================
-- 2) 마스터(거래처/품목/설비)
-- =========================================================

CREATE TABLE IF NOT EXISTS tb_mes_cnpt000 (
  cnpt_cd    VARCHAR(50) PRIMARY KEY,
  cnpt_nm    VARCHAR(200) NOT NULL,
  use_yn     CHAR(1) NOT NULL DEFAULT 'Y',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE tb_mes_cnpt000 IS '거래처(고객사) 마스터';
COMMENT ON COLUMN tb_mes_cnpt000.cnpt_cd IS '거래처 코드(PK)';
COMMENT ON COLUMN tb_mes_cnpt000.cnpt_nm IS '거래처명';

CREATE TABLE IF NOT EXISTS tb_mes_item100 (
  item_cd    VARCHAR(50) PRIMARY KEY,
  item_nm    VARCHAR(200) NOT NULL,
  spec_json  JSONB,
  use_yn     CHAR(1) NOT NULL DEFAULT 'Y',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP
);

COMMENT ON TABLE tb_mes_item100 IS '품목 마스터';
COMMENT ON COLUMN tb_mes_item100.item_cd IS '품목 코드(PK)';
COMMENT ON COLUMN tb_mes_item100.spec_json IS '품목 확장 스펙(JSONB)';

CREATE INDEX IF NOT EXISTS idx_item_spec_json_gin ON tb_mes_item100 USING GIN (spec_json);

CREATE TABLE IF NOT EXISTS tb_mes_equip000 (
  equip_cd   VARCHAR(50) PRIMARY KEY,
  equip_nm   VARCHAR(200) NOT NULL,
  line_cd    VARCHAR(50),
  use_yn     CHAR(1) NOT NULL DEFAULT 'Y',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE tb_mes_equip000 IS '설비 마스터';
COMMENT ON COLUMN tb_mes_equip000.equip_cd IS '설비 코드(PK)';
COMMENT ON COLUMN tb_mes_equip000.line_cd IS '라인 코드(선택)';

-- =========================================================
-- 3) 공정 템플릿(설계 핵심)
-- =========================================================

CREATE TABLE IF NOT EXISTS tb_mes_prcs_template100 (
  prcs_template_cd VARCHAR(50) PRIMARY KEY,
  prcs_template_nm VARCHAR(200) NOT NULL,
  version_no       INT NOT NULL DEFAULT 1,
  use_yn           CHAR(1) NOT NULL DEFAULT 'Y',
  created_by       VARCHAR(50),
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by       VARCHAR(50),
  updated_at       TIMESTAMP
);

COMMENT ON TABLE tb_mes_prcs_template100 IS '공정 템플릿 헤더';
COMMENT ON COLUMN tb_mes_prcs_template100.version_no IS '버전 번호';

CREATE TABLE IF NOT EXISTS tb_mes_unit_prcs110 (
  unit_prcs_id     BIGSERIAL PRIMARY KEY,
  prcs_template_cd VARCHAR(50) NOT NULL, 
  unit_prcs_cd     VARCHAR(50) NOT NULL, 
  unit_prcs_nm     VARCHAR(200),
  seq_no           INT NOT NULL,
  std_time_sec     INT,
  use_yn           CHAR(1) NOT NULL DEFAULT 'Y',
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP,
  UNIQUE (prcs_template_cd, unit_prcs_cd),
  UNIQUE (prcs_template_cd, seq_no)
);

COMMENT ON TABLE tb_mes_unit_prcs110 IS '단위 공정';
COMMENT ON COLUMN tb_mes_unit_prcs110.prcs_template_cd IS '템플릿 코드';
COMMENT ON COLUMN tb_mes_unit_prcs110.seq_no IS '공정 순서';

CREATE INDEX IF NOT EXISTS idx_unit_prcs_template_seq ON tb_mes_unit_prcs110(prcs_template_cd, seq_no);

CREATE TABLE IF NOT EXISTS tb_mes_prcs_dept_his010 (
  prcs_dept_map_id BIGSERIAL PRIMARY KEY,
  unit_prcs_id     BIGINT NOT NULL,     -- FK 미사용: tb_mes_unit_prcs110.unit_prcs_id
  dept_cd          VARCHAR(50) NOT NULL,-- FK 미사용: tb_mes_dept000.dept_cd
  effective_from   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  effective_to     TIMESTAMP,
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE tb_mes_prcs_dept_his010 IS '공정-부서 매핑 이력';
COMMENT ON COLUMN tb_mes_prcs_dept_his010.unit_prcs_id IS '단위 공정 ID';
COMMENT ON COLUMN tb_mes_prcs_dept_his010.dept_cd IS '부서 코드';
COMMENT ON COLUMN tb_mes_prcs_dept_his010.effective_to IS '종료 시각';

CREATE INDEX IF NOT EXISTS idx_prcs_dept_his_unit_from
  ON tb_mes_prcs_dept_his010(unit_prcs_id, effective_from DESC);

CREATE INDEX IF NOT EXISTS idx_prcs_dept_his_dept_cd
  ON tb_mes_prcs_dept_his010(dept_cd);

CREATE TABLE IF NOT EXISTS tb_mes_item_template_map120 (
  item_cd          VARCHAR(50) NOT NULL,
  prcs_template_cd VARCHAR(50) NOT NULL,
  active_yn        CHAR(1) NOT NULL DEFAULT 'Y',
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (item_cd, prcs_template_cd)
);

COMMENT ON TABLE tb_mes_item_template_map120 IS '품목-공정 템플릿 매핑';
COMMENT ON COLUMN tb_mes_item_template_map120.item_cd IS '품목 코드';
COMMENT ON COLUMN tb_mes_item_template_map120.prcs_template_cd IS '공정 템플릿 코드';
COMMENT ON COLUMN tb_mes_item_template_map120.active_yn IS '활성 여부';

CREATE INDEX IF NOT EXISTS idx_item_template_map_active ON tb_mes_item_template_map120(active_yn);

-- =========================================================
-- 4) 주문 → 생산(작업 흐름)
-- =========================================================

CREATE TABLE IF NOT EXISTS tb_mes_ord000 (
  ord_cd          VARCHAR(50) PRIMARY KEY,
  cnpt_cd         VARCHAR(50) NOT NULL,
  delivery_req_dt DATE,
  ord_st_cd       VARCHAR(50) NOT NULL DEFAULT 'NEW',
  created_by      VARCHAR(50),
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE tb_mes_ord000 IS '주문 헤더';
COMMENT ON COLUMN tb_mes_ord000.cnpt_cd IS '거래처 코드';
COMMENT ON COLUMN tb_mes_ord000.ord_st_cd IS '주문 상태';

CREATE INDEX IF NOT EXISTS idx_ord_cnpt_cd ON tb_mes_ord000(cnpt_cd);
CREATE INDEX IF NOT EXISTS idx_ord_delivery_req_dt ON tb_mes_ord000(delivery_req_dt);

CREATE TABLE IF NOT EXISTS tb_mes_ord100 (
  ord_item_cd VARCHAR(50) PRIMARY KEY,
  ord_cd      VARCHAR(50) NOT NULL, 
  item_cd     VARCHAR(50) NOT NULL, 
  ord_cnt     NUMERIC(14,3) NOT NULL DEFAULT 0,
  due_dt      DATE,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE tb_mes_ord100 IS '주문 품목 라인';
COMMENT ON COLUMN tb_mes_ord100.ord_cd IS '주문 코드';
COMMENT ON COLUMN tb_mes_ord100.item_cd IS '품목 코드';

CREATE INDEX IF NOT EXISTS idx_ord100_ord_cd ON tb_mes_ord100(ord_cd);
CREATE INDEX IF NOT EXISTS idx_ord100_item_cd ON tb_mes_ord100(item_cd);

CREATE TABLE IF NOT EXISTS tb_mes_opr000 (
  opr_cd                VARCHAR(50) PRIMARY KEY,
  ord_item_cd           VARCHAR(50) NOT NULL, 
  opr_st_cd             VARCHAR(50) NOT NULL DEFAULT 'WAIT',
  item_prcs_template_cd VARCHAR(50),  
  started_at            TIMESTAMP,
  finished_at           TIMESTAMP,
  created_by            VARCHAR(50), 
  created_at            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by            VARCHAR(50),
  updated_at            TIMESTAMP
);

COMMENT ON TABLE tb_mes_opr000 IS '작업지시/공정이동표(주문 품목 기준 생산 작업 단위)';
COMMENT ON COLUMN tb_mes_opr000.ord_item_cd IS '주문 품목 코드';
COMMENT ON COLUMN tb_mes_opr000.item_prcs_template_cd IS '사용 템플릿 코드';
COMMENT ON COLUMN tb_mes_opr000.opr_st_cd IS '작업 상태';

-- 주문품목 1건당 작업 1건 운영 (정책)
CREATE UNIQUE INDEX IF NOT EXISTS uq_opr_ord_item_cd ON tb_mes_opr000(ord_item_cd);
CREATE INDEX IF NOT EXISTS idx_opr_status ON tb_mes_opr000(opr_st_cd);
CREATE INDEX IF NOT EXISTS idx_opr_created_at ON tb_mes_opr000(created_at);

CREATE TABLE IF NOT EXISTS tb_mes_opr_step100 (
  opr_step_id   BIGSERIAL PRIMARY KEY,
  opr_cd        VARCHAR(50) NOT NULL, 
  unit_prcs_id  BIGINT NOT NULL,      
  seq_no        INT NOT NULL,  
  step_st_cd    VARCHAR(50) NOT NULL DEFAULT 'WAIT',
  start_at      TIMESTAMP,
  end_at        TIMESTAMP,
  worker_id     VARCHAR(50),  
  abnormal_rmrk VARCHAR(2000),
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP,
  UNIQUE (opr_cd, seq_no)
);

COMMENT ON TABLE tb_mes_opr_step100 IS '작업 단위공정 실행 이력(템플릿을 펼쳐 생성되는 실행 단계)';
COMMENT ON COLUMN tb_mes_opr_step100.opr_cd IS '작업 코드';
COMMENT ON COLUMN tb_mes_opr_step100.unit_prcs_id IS '단위공정 ID';
COMMENT ON COLUMN tb_mes_opr_step100.seq_no IS '공정 순서';

CREATE INDEX IF NOT EXISTS idx_opr_step_opr_seq ON tb_mes_opr_step100(opr_cd, seq_no);
CREATE INDEX IF NOT EXISTS idx_opr_step_status ON tb_mes_opr_step100(step_st_cd);

CREATE TABLE IF NOT EXISTS tb_mes_lot000 (
  lot_cd     VARCHAR(50) PRIMARY KEY,
  opr_cd     VARCHAR(50) NOT NULL, 
  item_cd    VARCHAR(50) NOT NULL,
  qty        NUMERIC(14,3) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE tb_mes_lot000 IS 'LOT(생산 단위 식별자)';
COMMENT ON COLUMN tb_mes_lot000.opr_cd IS '작업 코드';
COMMENT ON COLUMN tb_mes_lot000.item_cd IS '품목 코드';

CREATE INDEX IF NOT EXISTS idx_lot_opr_cd ON tb_mes_lot000(opr_cd);
CREATE INDEX IF NOT EXISTS idx_lot_created_at ON tb_mes_lot000(created_at);

-- =========================================================
-- 5) 클레임 / 첨부
-- =========================================================

CREATE TABLE IF NOT EXISTS tb_mes_claim000 (
  claim_cd      VARCHAR(50) PRIMARY KEY,
  opr_cd        VARCHAR(50) NOT NULL, 
  claim_type_cd VARCHAR(50) NOT NULL, 
  claim_st_cd   VARCHAR(50) NOT NULL DEFAULT 'OPEN',
  iss_rmrk      VARCHAR(4000) NOT NULL,
  created_by    VARCHAR(50),
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    VARCHAR(50),
  updated_at    TIMESTAMP
);

COMMENT ON TABLE tb_mes_claim000 IS '클레임/품질 이슈';
COMMENT ON COLUMN tb_mes_claim000.opr_cd IS '작업 코드';
COMMENT ON COLUMN tb_mes_claim000.claim_st_cd IS '상태';

CREATE INDEX IF NOT EXISTS idx_claim_opr_cd ON tb_mes_claim000(opr_cd);
CREATE INDEX IF NOT EXISTS idx_claim_status ON tb_mes_claim000(claim_st_cd);

CREATE TABLE IF NOT EXISTS tb_mes_file000 (
  file_id      UUID PRIMARY KEY,
  ref_type     VARCHAR(50) NOT NULL, 
  ref_id       VARCHAR(50) NOT NULL,
  file_kind    VARCHAR(50) NOT NULL, 
  orig_name    VARCHAR(255) NOT NULL,
  mime_type    VARCHAR(100),
  storage_path VARCHAR(1000) NOT NULL,
  created_by   VARCHAR(50),
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE tb_mes_file000 IS '첨부파일 공통';
COMMENT ON COLUMN tb_mes_file000.ref_type IS '참조 타입';
COMMENT ON COLUMN tb_mes_file000.ref_id IS '참조 ID';
COMMENT ON COLUMN tb_mes_file000.storage_path IS '파일 저장 경로';

CREATE INDEX IF NOT EXISTS idx_file_ref ON tb_mes_file000(ref_type, ref_id);
CREATE INDEX IF NOT EXISTS idx_file_created_at ON tb_mes_file000(created_at);

-- =========================================================
-- 6) 설비 센서 / 알람
-- =========================================================

CREATE TABLE IF NOT EXISTS tb_mes_sensor_reading000 (
  reading_id BIGSERIAL PRIMARY KEY,
  equip_cd   VARCHAR(50) NOT NULL, 
  tag_cd     VARCHAR(50) NOT NULL, 
  val        NUMERIC(18,6) NOT NULL,
  read_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE tb_mes_sensor_reading000 IS '설비 센서 데이터';
COMMENT ON COLUMN tb_mes_sensor_reading000.equip_cd IS '설비 코드';
COMMENT ON COLUMN tb_mes_sensor_reading000.tag_cd IS '센서 태그 코드';
COMMENT ON COLUMN tb_mes_sensor_reading000.read_at IS '측정 시각';

CREATE INDEX IF NOT EXISTS idx_sensor_equip_read_at
  ON tb_mes_sensor_reading000(equip_cd, read_at DESC);

CREATE INDEX IF NOT EXISTS idx_sensor_tag_read_at
  ON tb_mes_sensor_reading000(tag_cd, read_at DESC);

CREATE TABLE IF NOT EXISTS tb_mes_alarm000 (
  alarm_id     BIGSERIAL PRIMARY KEY,
  equip_cd     VARCHAR(50) NOT NULL, 
  tag_cd       VARCHAR(50) NOT NULL,
  threshold    NUMERIC(18,6) NOT NULL,
  current_val  NUMERIC(18,6) NOT NULL,
  alarm_level  VARCHAR(20) NOT NULL, 
  alarm_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  resolved_at  TIMESTAMP
);

COMMENT ON TABLE tb_mes_alarm000 IS '임계치 기반 알람(실시간 모니터링/알림용)';
COMMENT ON COLUMN tb_mes_alarm000.equip_cd IS '설비 코드';
COMMENT ON COLUMN tb_mes_alarm000.resolved_at IS '해제 시각';

CREATE INDEX IF NOT EXISTS idx_alarm_equip_alarm_at
  ON tb_mes_alarm000(equip_cd, alarm_at DESC);

COMMIT;
