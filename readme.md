## 📊 Database Architecture (ERD)
The following diagram illustrates the relational structure of the system, highlighting how ranking cycles, institutional tasks, and user responses are interconnected.

![Database ERD Diagram](/assets/ERD.png)

---

## ⚙️ Data Flow Logic
The system follows a linear workflow to ensure data accountability and organized collection:

1.  **Cycle Initiation**: A **Ranking Cycle** is established (e.g., 2026 Sustainability Index) containing a specific set of **Questions**.
2.  **Delegation**: Questions are distributed to specific **Departments** through the **Task Assignments** table.
3.  **Data Entry**: **Users** assigned to those departments access their specific tasks to provide **Answers**.
4.  **Tracking & Completion**: The system monitors the **Status** (Pending, Submitted, etc.) of each assignment until the cycle **Deadline** is reached.