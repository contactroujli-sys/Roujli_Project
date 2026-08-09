const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  try {
    const reportCount = await prisma.report.count();
    console.log(`Successfully connected! Found ${reportCount} reports.`);
  } catch (e) {
    console.error('Error connecting:', e);
  } finally {
    await prisma.$disconnect();
  }
}
main();
