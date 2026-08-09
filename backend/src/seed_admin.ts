import prisma from "./config/prisma.js";
import { hashPassword } from "./utils/password.js";

async function main() {
  const email = "admin@roujli.com";
  let user = await prisma.user.findUnique({ where: { email } });

  if (user) {
    console.log("Admin user already exists. Updating role and verifying...");
    user = await prisma.user.update({
      where: { email },
      data: { role: "ADMIN", isVerified: true },
    });
    console.log("Admin user updated successfully.");
  } else {
    console.log("Admin user not found. Creating one...");
    const hashedPassword = await hashPassword("admin");
    user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        role: "ADMIN",
        isVerified: true,
        profile: {
          create: {
            firstName: "Super",
            lastName: "Admin",
          }
        }
      }
    });
    console.log("Admin user created successfully.");
  }
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
