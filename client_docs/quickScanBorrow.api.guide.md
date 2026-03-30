# Huong dan su dung API quickScanBorrow

Tai lieu nay mo ta day du cach goi API scan nhanh de tao phieu muon phom tu danh sach EPC da scan.
Muc tieu: client chi can chon DepID va gui danh sach EPC, backend se tu xu ly va tra ve ket qua theo tung LastMatNo.

## 1) Thong tin endpoint

- Method: POST
- URL: /api/phom/quickScanBorrow
- Content-Type: application/json

Vi du full URL:
- http://localhost:3000/api/phom/quickScanBorrow

## 2) Chuc nang API

API se:
- Nhan danh sach EPC da scan
- Tu loai bo EPC trung lap trong request
- Tim thong tin EPC trong Last_Data_Binding
- Tach EPC loi thanh 3 nhom:
  - notFoundEPC: EPC khong ton tai trong bang binding
  - outEPC: EPC da o trang thai isOut = 1
  - lostEPC: EPC co isLost = 1
- Lay EPC hop le va nhom theo LastMatNo
- Neu co nhieu LastMatNo, API se tu tao nhieu bill (moi LastMatNo 1 bill)
- Tu tao detail bill, scan out, cap nhat isOut va ghi LastInOut A/M/D

## 3) Request body

Co cac truong bat buoc va tuy chon nhu sau:

### Bat buoc
- companyName: string
- DepID: string
- Danh sach EPC (chay theo uu tien key):
  - EPCList: string[]
  - hoac epcList: string[]
  - hoac ListEPC: string[]

### Tuy chon
- UserID: string (neu khong truyen, backend mac dinh SYSTEM)
- userId: string (duoc chap nhan nhu UserID)
- OfficerId: string (neu khong truyen, backend de rong)
- DateBorrow: string (neu khong truyen, backend dung thoi gian hien tai)
- DateReceive: string (neu khong truyen, backend lay bang DateBorrow)

## 4) Vi du request

```json
{
  "companyName": "LHG",
  "DepID": "D01",
  "UserID": "U1001",
  "OfficerId": "O2001",
  "DateBorrow": "2026-03-30 08:00:00",
  "DateReceive": "2026-03-31 17:00:00",
  "EPCList": [
    "EPC_A_001",
    "EPC_A_002",
    "EPC_B_001",
    "EPC_B_002"
  ]
}
```

## 5) Response thanh cong

Khi thanh cong, API tra ve:
- status = "Success"
- statusCode = 200
- data.totalBills: so bill da tao
- data.bills: danh sach bill theo tung LastMatNo
- invalidEPC: danh sach EPC loi (neu co)

### Vi du response thanh cong

```json
{
  "status": "Success",
  "statusCode": 200,
  "data": {
    "DepID": "D01",
    "totalBills": 2,
    "bills": [
      {
        "ID_BILL": "B000123",
        "LastInOutNo": "IO000567",
        "DepID": "D01",
        "LastMatNo": "MATNO_A",
        "details": [
          { "LastMatNo": "MATNO_A", "LastName": "LAST_A", "LastSize": "40", "LastSum": 1 },
          { "LastMatNo": "MATNO_A", "LastName": "LAST_A", "LastSize": "41", "LastSum": 1 }
        ],
        "scannedEPC": ["EPC_A_001", "EPC_A_002"]
      },
      {
        "ID_BILL": "B000124",
        "LastInOutNo": "IO000568",
        "DepID": "D01",
        "LastMatNo": "MATNO_B",
        "details": [
          { "LastMatNo": "MATNO_B", "LastName": "LAST_B", "LastSize": "42", "LastSum": 1 }
        ],
        "scannedEPC": ["EPC_B_001", "EPC_B_002"]
      }
    ]
  },
  "invalidEPC": {
    "notFoundEPC": ["EPC_X_999"],
    "outEPC": ["EPC_OUT_001"],
    "lostEPC": ["EPC_LOST_001"]
  },
  "message": "Scan nhanh thanh cong."
}
```

## 6) Response loi thuong gap

### 400 - Thieu du lieu
- status = Error
- message: "Thieu companyName, DepID hoac danh sach EPC."

### 400 - Danh sach EPC khong hop le
- status = Error
- message: "Danh sach EPC khong hop le."

### 400 - Khong co EPC hop le
- status = Error
- invalidEPC co du 3 nhom
- message: "Khong co EPC hop le de tao phieu muon."

### 500 - Loi server
- status = Error
- message: "Loi khi scan nhanh phieu muon."

## 7) Luu y quan trong cho client

- API co the tao nhieu bill trong 1 request khi co nhieu LastMatNo.
- Luon doc data.bills thay vi chi doc 1 ID_BILL.
- Luon hien thi invalidEPC de user biet EPC nao bi loi.
- Backend hien tai chua dung transaction tong cho toan bo request:
  - Neu loi giua chung, co the da tao mot phan du lieu.
  - Client nen thong bao ket qua thuc te theo response hien co.

## 8) TypeScript interfaces de AI/frontend dung nhanh

```ts
export interface QuickScanBorrowRequest {
  companyName: string;
  DepID: string;
  EPCList?: string[];
  epcList?: string[];
  ListEPC?: string[];
  UserID?: string;
  userId?: string;
  OfficerId?: string;
  DateBorrow?: string;
  DateReceive?: string;
}

export interface QuickScanBorrowDetail {
  LastMatNo: string;
  LastName: string;
  LastSize: string;
  LastSum: number;
}

export interface QuickScanBorrowBill {
  ID_BILL: string;
  LastInOutNo: string;
  DepID: string;
  LastMatNo: string;
  details: QuickScanBorrowDetail[];
  scannedEPC: string[];
}

export interface QuickScanBorrowResponse {
  status: "Success" | "Error";
  statusCode: number;
  data: {
    DepID?: string;
    totalBills?: number;
    bills?: QuickScanBorrowBill[];
  } | [];
  invalidEPC?: {
    notFoundEPC: string[];
    outEPC: string[];
    lostEPC: string[];
  };
  message: string;
}
```

## 9) Mau code client bang axios

```ts
import axios from "axios";

const api = axios.create({
  baseURL: "http://localhost:3000",
  timeout: 30000,
  headers: { "Content-Type": "application/json" },
});

export async function quickScanBorrow(input: {
  companyName: string;
  depID: string;
  epcList: string[];
  userID?: string;
  officerId?: string;
  dateBorrow?: string;
  dateReceive?: string;
}) {
  const payload = {
    companyName: input.companyName,
    DepID: input.depID,
    UserID: input.userID,
    OfficerId: input.officerId,
    DateBorrow: input.dateBorrow,
    DateReceive: input.dateReceive,
    EPCList: input.epcList,
  };

  const res = await api.post("/api/phom/quickScanBorrow", payload);
  const data = res.data;

  if (data.status !== "Success") {
    throw new Error(data.message || "quickScanBorrow failed");
  }

  return {
    bills: data.data?.bills ?? [],
    totalBills: data.data?.totalBills ?? 0,
    invalidEPC: data.invalidEPC ?? {
      notFoundEPC: [],
      outEPC: [],
      lostEPC: [],
    },
    raw: data,
  };
}
```

## 10) Mau code client bang fetch

```ts
export async function quickScanBorrowFetch(payload: {
  companyName: string;
  DepID: string;
  EPCList: string[];
  UserID?: string;
  OfficerId?: string;
  DateBorrow?: string;
  DateReceive?: string;
}) {
  const res = await fetch("http://localhost:3000/api/phom/quickScanBorrow", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });

  const data = await res.json();

  if (!res.ok || data.status !== "Success") {
    throw new Error(data?.message || "quickScanBorrow failed");
  }

  return data;
}
```

## 11) Goi y prompt cho AI de sinh code client dung dung API

Ban co the dua nguyen prompt mau sau cho AI code assistant:

"Hay viet client TypeScript goi API POST /api/phom/quickScanBorrow. Dau vao gom companyName, DepID, EPCList. API co the tra ve nhieu bill trong data.bills, vui long map ket qua theo LastMatNo, hien thi danh sach invalidEPC (notFoundEPC, outEPC, lostEPC), va xu ly loi theo message tu backend."

## 12) Checklist test nhanh

- Case 1: Tat ca EPC hop le, cung 1 LastMatNo -> totalBills = 1
- Case 2: Tat ca EPC hop le, nhieu LastMatNo -> totalBills > 1
- Case 3: EPC tron hop le + khong ton tai + da out + da lost -> invalidEPC co du nhom
- Case 4: Thieu DepID hoac EPCList rong -> API tra loi 400
