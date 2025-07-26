## FEATURE:

- สร้างแอปที่ 4 Subnet Calculator ที่ช่วยในการคำนวณ Subnet Mask และสามารถตรวจสอบว่า IP Address ที่ระบุอยู่ใน Subnet ที่กำหนดหรือไม่

## USER STORY:

ในฐานะผู้ดูแลระบบเครือข่าย : การคำนวณ Subnet Mask
- ฉันต้องการ ป้อน IP Address และ Prefix Length (CIDR) เพื่อที่ฉันจะได้ ทราบ Network Address, Broadcast Address และช่วง IP Address ที่ใช้งานได้ สำหรับเครือข่ายนั้นๆ ได้อย่างรวดเร็ว
- ฉันต้องการ ป้อน IP Address และ Subnet Mask เพื่อที่ฉันจะได้ ทราบ Prefix Length (CIDR), Network Address, Broadcast Address และจำนวน Host ที่ใช้งานได้ สำหรับการวางแผนเครือข่าย

ในฐานะผู้ดูแลระบบเครือข่าย : การตรวจสอบ IP Address ใน Subnet
- ฉันต้องการ ป้อน IP Address ที่ต้องการตรวจสอบ และระบุ Network Address/Subnet Mask ของ Subnet เพื่อที่ฉันจะได้ ยืนยันได้อย่างรวดเร็วว่า IP Address นั้นอยู่ใน Subnet ที่กำหนดหรือไม่ เช่น เพื่อแก้ปัญหาการเชื่อมต่อหรือยืนยันการกำหนดค่า
- ฉันต้องการ ตรวจสอบ IP Address หลายๆ IP เทียบกับ Subnet ที่กำหนด เพื่อที่ฉันจะได้ ประหยัดเวลาในการตรวจสอบด้วยตนเอง และมั่นใจในความถูกต้อง

### User experience and error handling
ในฐานะผู้ใช้งาน
- ฉันต้องการ ป้อนข้อมูล IP Address หรือ Subnet Mask ที่ผิดพลาด แล้ว ได้รับข้อความแจ้งเตือนที่ชัดเจน เพื่อที่ฉันจะได้ แก้ไขข้อมูลได้อย่างถูกต้อง และไม่เสียเวลา
- ฉันต้องการ เห็นผลลัพธ์การคำนวณในรูปแบบที่อ่านง่ายและจัดระเบียบอย่างดี เพื่อที่ฉันจะได้ เข้าใจข้อมูลได้อย่างรวดเร็ว โดยไม่ต้องตีความซับซ้อน

## SCOPE OF WORK:

### 1. การออกแบบ User Interface (UI) และ User Experience (UX)

* **ออกแบบหน้าจอหลัก** ที่ใช้งานง่ายสำหรับป้อน **IP Address** และ **Prefix Length (CIDR)** หรือ **Subnet Mask**
* **ออกแบบหน้าจอแสดงผลลัพธ์** การคำนวณ Subnet ที่ชัดเจนและเป็นระเบียบ
* **ออกแบบหน้าจอสำหรับฟังก์ชันตรวจสอบ** เพื่อป้อน IP Address ที่ต้องการตรวจสอบ และ Subnet ที่ต้องการเปรียบเทียบ
* **คำนึงถึงความสะดวกในการใช้งาน** และความสามารถในการเข้าใจข้อมูลที่แสดงผลบนหน้าจอ

### 2. การพัฒนาฟังก์ชันการคำนวณ Subnet Mask

* ผู้ใช้สามารถ **ป้อน IP Address** (เช่น 192.168.1.0)
* ผู้ใช้สามารถ **เลือกหรือป้อน Prefix Length** (เช่น /24) หรือ **Subnet Mask** (เช่น 255.255.255.0)
* แอปพลิเคชันต้องสามารถคำนวณและ **แสดงผลลัพธ์** ต่อไปนี้:
    * **Network Address** (ที่อยู่เครือข่าย)
    * **Broadcast Address** (ที่อยู่สำหรับแพร่สัญญาณ)
    * **First Usable Host** (IP Address แรกที่ใช้งานได้)
    * **Last Usable Host** (IP Address สุดท้ายที่ใช้งานได้)
    * **Number of Usable Hosts** (จำนวน IP Address ที่ใช้งานได้)
    * **Subnet Mask** (กรณีป้อน Prefix Length)
    * **Prefix Length** (กรณีป้อน Subnet Mask)

### 3. การพัฒนาฟังก์ชันตรวจสอบ IP Address ใน Subnet

* ผู้ใช้สามารถ **ป้อน IP Address** ที่ต้องการตรวจสอบ
* ผู้ใช้สามารถ **ป้อน Network Address** และ **Subnet Mask หรือ Prefix Length** ของ Subnet ที่ต้องการเปรียบเทียบ
* แอปพลิเคชันต้องสามารถ **ตรวจสอบและระบุ** ได้อย่างชัดเจนว่า IP Address ที่ป้อน **อยู่ใน** หรือ **ไม่อยู่ใน** Subnet ที่กำหนด

### 4. การจัดการข้อผิดพลาด (Error Handling)

* **ตรวจสอบความถูกต้องของข้อมูล** ที่ผู้ใช้ป้อน (เช่น รูปแบบ IP Address ที่ถูกต้อง, Prefix Length ที่อยู่ในช่วงที่กำหนด)
* **แสดงข้อความแจ้งเตือนที่ชัดเจน** และเข้าใจง่ายเมื่อพบข้อมูลที่ไม่ถูกต้อง

### 5. การทดสอบ (Testing)

* **ทดสอบฟังก์ชันการคำนวณทั้งหมด** ด้วยข้อมูลที่หลากหลาย ครอบคลุม IP Classes และ Prefix Lengths ต่างๆ
* **ทดสอบฟังก์ชันการตรวจสอบ IP Address** ทั้งกรณีที่ IP Address นั้นอยู่ใน Subnet และไม่อยู่ใน Subnet
* **ทดสอบการจัดการข้อผิดพลาด** เพื่อให้แน่ใจว่าระบบสามารถแจ้งเตือนผู้ใช้ได้อย่างถูกต้อง

## DOCUMENTATION:

The project should be a `flutter`
- https://docs.flutter.dev/get-started/fundamentals

## ACCEPTANCE CRITERIA:

- UX/UI must be taken into account, no complexity required.
- Easy to improve and further develop.
- The interface is easy to use and has a uniform layout.