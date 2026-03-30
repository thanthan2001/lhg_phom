# Huong dan su dung API getphomrfid

Tai lieu nay mo ta cach goi API tim thong tin phom theo RFID.

## 1) Thong tin endpoint

- Method: POST
- URL route: /api/phom/getphomrfid
- Content-Type: application/json

Vi du full URL:
- http://localhost:3000/api/phom/getphomrfid

## 2) Chuc nang API

API se:
- Nhan RFID tu client
- Tim du lieu trong bang Last_Data_Binding theo RFID
- Tra ve thong tin phom neu tim thay
- Tra ve thong bao "Chua binding" neu chua co binding

## 3) Request body

### Bat buoc
- companyName: string
- RFID: string

### Vi du request

```json
{
  "companyName": "LHG",
  "RFID": "E2806894000040038668A3D1"
}
```

## 4) Response thanh cong khi tim thay

Khi RFID da duoc binding, API tra ve:
- status = "Success"
- statusCode = 200
- data = danh sach record tim duoc trong Last_Data_Binding
- message = "Lay phom thanh cong."

Vi du:

```json
{
  "status": "Success",
  "statusCode": 200,
  "data": [
    {
      "RFID": "E2806894000040038668A3D1",
      "LastMatNo": "MATNO_001",
      "LastNo": "LAST001",
      "LastSize": "40",
      "LastSide": "R",
      "isOut": 0,
      "isLost": 0
    }
  ],
  "message": "Lay phom thanh cong."
}
```

## 5) Response khi chua binding

Khi khong tim thay RFID trong Last_Data_Binding, API tra ve:
- status = "Chua binding"
- statusCode = 204
- data = []
- message = "Khong co phom nao"

Vi du:

```json
{
  "status": "Chua binding",
  "statusCode": 204,
  "data": [],
  "message": "Khong co phom nao"
}
```

## 6) Response loi he thong

Khi co exception trong qua trinh truy van, API tra ve:
- status = "Error"
- statusCode = 500
- data = []
- message = "Loi khi lay phom."

Vi du:

```json
{
  "status": "Error",
  "statusCode": 500,
  "data": [],
  "message": "Loi khi lay phom."
}
```

## 7) Luu y quan trong

- Controller hien tai tra HTTP status 200 cho cac truong hop co response object.
- Trang thai nghiep vu can doc trong body qua 2 truong:
  - status
  - statusCode
- Vi vay, client khong nen chi dua vao HTTP code de ket luan ket qua.

## 8) Mau goi nhanh bang curl

```bash
curl -X POST "http://localhost:3000/api/phom/getphomrfid" \
  -H "Content-Type: application/json" \
  -d '{
    "companyName": "LHG",
    "RFID": "E2806894000040038668A3D1"
  }'
```

## 9) Mau goi bang axios

```ts
import axios from "axios";

export async function getPhomByRFID(input: { companyName: string; RFID: string }) {
  const res = await axios.post("http://localhost:3000/api/phom/getphomrfid", input, {
    headers: { "Content-Type": "application/json" },
    timeout: 15000,
  });

  const data = res.data;

  if (data.statusCode !== 200) {
    return {
      ok: false,
      status: data.status,
      statusCode: data.statusCode,
      message: data.message,
      data: data.data || [],
    };
  }

  return {
    ok: true,
    status: data.status,
    statusCode: data.statusCode,
    message: data.message,
    data: data.data || [],
  };
}
```

## 10) Checklist test nhanh

- Case 1: RFID da binding -> statusCode = 200, data co phan tu
- Case 2: RFID chua binding -> statusCode = 204, data rong
- Case 3: payload thieu companyName hoac RFID -> can bo sung validate o backend neu muon chan som
- Case 4: loi DB/exception -> statusCode = 500
